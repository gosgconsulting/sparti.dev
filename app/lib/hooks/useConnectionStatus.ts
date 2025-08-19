import { useState, useEffect } from 'react';
import { checkConnection } from '~/lib/api/connection';

const ACKNOWLEDGED_CONNECTION_ISSUE_KEY = 'bolt_acknowledged_connection_issue';

type ConnectionIssueType = 'disconnected' | 'high-latency' | null;

const getAcknowledgedIssue = (): string | null => {
  try {
    return localStorage.getItem(ACKNOWLEDGED_CONNECTION_ISSUE_KEY);
  } catch {
    return null;
  }
};

export const useConnectionStatus = () => {
  const [hasConnectionIssues, setHasConnectionIssues] = useState(false);
  const [currentIssue, setCurrentIssue] = useState<ConnectionIssueType>(null);
  const [acknowledgedIssue, setAcknowledgedIssue] = useState<string | null>(() => getAcknowledgedIssue());
  const [isOnline, setIsOnline] = useState(() => navigator.onLine);

  const checkStatus = async () => {
    try {
      // Skip check if browser reports offline
      if (!isOnline) {
        setCurrentIssue('disconnected');
        setHasConnectionIssues('disconnected' !== acknowledgedIssue);
        return;
      }

      const status = await checkConnection();
      const issue = !status.connected ? 'disconnected' : status.latency > 1000 ? 'high-latency' : null;

      setCurrentIssue(issue);

      // Only show issues if they're new or different from the acknowledged one
      setHasConnectionIssues(issue !== null && issue !== acknowledgedIssue);
    } catch (error) {
      // Handle errors more gracefully - don't automatically assume disconnected
      const wasConnected = currentIssue === null;
      if (wasConnected) {
        // Only set as disconnected if we were previously connected
        setCurrentIssue('disconnected');
        setHasConnectionIssues('disconnected' !== acknowledgedIssue);
      }
      // Otherwise keep the current state
    }
  };

  useEffect(() => {
    // Listen to online/offline events
    const handleOnline = () => {
      setIsOnline(true);
      // Check connection when coming back online
      setTimeout(checkStatus, 1000);
    };

    const handleOffline = () => {
      setIsOnline(false);
      setCurrentIssue('disconnected');
      setHasConnectionIssues('disconnected' !== acknowledgedIssue);
    };

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    // Initial check
    checkStatus();

    // Check every 30 seconds instead of 10 to reduce frequency
    const interval = setInterval(checkStatus, 30 * 1000);

    return () => {
      clearInterval(interval);
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, [acknowledgedIssue]);

  const acknowledgeIssue = () => {
    try {
      localStorage.setItem(ACKNOWLEDGED_CONNECTION_ISSUE_KEY, currentIssue || '');
    } catch {
      // Ignore localStorage errors
    }
    setAcknowledgedIssue(currentIssue);
    setHasConnectionIssues(false);
  };

  const resetAcknowledgment = () => {
    try {
      localStorage.removeItem(ACKNOWLEDGED_CONNECTION_ISSUE_KEY);
    } catch {
      // Ignore localStorage errors
    }
    setAcknowledgedIssue(null);
    checkStatus();
  };

  return { hasConnectionIssues, currentIssue, acknowledgeIssue, resetAcknowledgment };
};
