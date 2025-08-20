# Use the official bolt.diy image as base
FROM ghcr.io/stackblitz-labs/bolt.diy:sha-bab9a64

# Set working directory
WORKDIR /app

# Copy custom logo files to public directory
COPY public/logo-light-styled.png /app/build/client/logo-light-styled.png
COPY public/logo-dark-styled.png /app/build/client/logo-dark-styled.png

# Also copy to the public directory structure that might be used in dev
COPY public/logo-light-styled.png /app/public/logo-light-styled.png
COPY public/logo-dark-styled.png /app/public/logo-dark-styled.png

# Override app-wide icons with Sparti logo
# Remix adds links in app/root.tsx to /favicon.png and /apple-touch-icon.png
COPY public/logo-light-styled.png /app/build/client/favicon.png
COPY public/logo-light-styled.png /app/public/favicon.png
COPY public/logo-light-styled.png /app/build/client/apple-touch-icon.png
COPY public/logo-light-styled.png /app/public/apple-touch-icon.png
COPY public/logo-light-styled.png /app/build/client/apple-touch-icon-precomposed.png
COPY public/logo-light-styled.png /app/public/apple-touch-icon-precomposed.png

# If present, also use vector logo for svg favicon paths
COPY public/logo.svg /app/build/client/favicon.svg
COPY public/logo.svg /app/public/favicon.svg

# Normalize other common logo filenames used across the app
COPY public/logo-light-styled.png /app/build/client/logo.png
COPY public/logo-light-styled.png /app/public/logo.png
COPY public/logo-light-styled.png /app/build/client/logo-light.png
COPY public/logo-light-styled.png /app/public/logo-light.png
COPY public/logo-dark-styled.png /app/build/client/logo-dark.png
COPY public/logo-dark-styled.png /app/public/logo-dark.png
COPY public/logo.svg /app/build/client/logo.svg
COPY public/logo.svg /app/public/logo.svg

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
