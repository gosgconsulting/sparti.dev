export interface ConnectionStatus {
  connected: boolean;
  latency: number;
  lastChecked: string;
}

export const checkConnection = async (): Promise<ConnectionStatus> => {
  try {
    // Check if we have network connectivity
    const online = navigator.onLine;

    if (!online) {
      return {
        connected: false,
        latency: 0,
        lastChecked: new Date().toISOString(),
      };
    }

    // Try multiple endpoints in case one fails
    const endpoints = [
      '/api/health',
      '/', // Fallback to root route
    ];

    let latency = 0;
    let connected = false;

    for (const endpoint of endpoints) {
      try {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 5000); // 5 second timeout

        const start = performance.now();
        const response = await fetch(endpoint, {
          method: 'HEAD',
          cache: 'no-cache',
          signal: controller.signal,
          headers: {
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            Pragma: 'no-cache',
          },
        });
        const end = performance.now();

        clearTimeout(timeoutId);

        if (response.ok) {
          latency = Math.round(end - start);
          connected = true;
          break;
        }
      } catch (endpointError) {
        // Silently handle fetch errors - they're expected when offline
        if (endpointError instanceof Error && endpointError.name === 'AbortError') {
          // Request was aborted due to timeout
          continue;
        }

        // Other fetch errors (network issues, CORS, etc.) - continue silently
        continue;
      }
    }

    return {
      connected,
      latency,
      lastChecked: new Date().toISOString(),
    };
  } catch (error) {
    // Only log unexpected errors, not network-related ones
    if (!(error instanceof TypeError && error.message.includes('fetch'))) {
      console.warn('Connection check encountered an unexpected error:', error);
    }
    return {
      connected: false,
      latency: 0,
      lastChecked: new Date().toISOString(),
    };
  }
};
