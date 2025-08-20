# Use the official bolt.diy image as base
FROM ghcr.io/stackblitz-labs/bolt.diy:sha-bab9a64 AS bolt-ai-production

# Set working directory
WORKDIR /app

# Railway requires the app to bind to 0.0.0.0 and use the PORT environment variable
ENV HOST=0.0.0.0
ENV PORT=${PORT:-5173}
ENV NODE_ENV=production
ENV RUNNING_IN_DOCKER=true

# Railway environment configuration
ENV VITE_HMR_HOST=0.0.0.0
ENV VITE_HMR_PORT=${PORT:-5173}
ENV VITE_HMR_PROTOCOL=ws
ENV VITE_LOG_LEVEL=info

# File watching configuration for Railway
ENV CHOKIDAR_USEPOLLING=true
ENV WATCHPACK_POLLING=true

# Security and performance
ENV FORCE_COLOR=0
ENV CI=true

# Expose the port that Railway will assign
EXPOSE ${PORT:-5173}

# Railway uses a different startup command, so we'll use the default from the base image
# The base image should already have the proper CMD/ENTRYPOINT

# Development target that reuses the production stage, ensuring docker build works
FROM bolt-ai-production AS bolt-ai-development