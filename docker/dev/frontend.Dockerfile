# Development Dockerfile for Frontend
# Supports Vue 3.5.31+, React, Angular, Svelte, or any Node.js-based frontend

FROM node:22-alpine

# Install Git (useful for some npm packages)
RUN apk add --no-cache git

# Set working directory
WORKDIR /app

# Seed the image with the frontend app so Docker volume fallback can populate /app
COPY package.json package-lock.json ./
RUN npm install
COPY index.html vite.config.ts tsconfig.json tsconfig.node.json ./
COPY .env.development ./
COPY .env.production ./
COPY src ./src

# Expose port for dev server
# Vite uses 5173, React/Next.js use 3000, Angular uses 4200
# We'll use 5173 as default but it can be changed
EXPOSE 5173

# Set environment variables for development
ENV NODE_ENV=development
ENV HOST=0.0.0.0
ENV PORT=5173

# Create a startup script that installs dependencies if needed and starts the dev server
RUN printf '%s\n' '#!/bin/sh' \
    'if [ ! -f package.json ]; then' \
    '    echo "Error: package.json not found. Please run init-frontend.sh first."' \
    '    exit 1' \
    'fi' \
    '' \
    '# Check if node_modules is missing or incomplete (vite not found)' \
    'if [ ! -d node_modules ] || [ ! -f node_modules/.bin/vite ]; then' \
    '    echo "Installing dependencies..."' \
    '    rm -rf node_modules' \
    '    if [ -f package-lock.json ]; then npm ci; else npm install; fi' \
    'fi' \
    '' \
    'echo "Starting development server..."' \
    'npm run dev -- --host 0.0.0.0' \
    > /start.sh && chmod +x /start.sh

# Start development server via the startup script
CMD ["/start.sh"]
