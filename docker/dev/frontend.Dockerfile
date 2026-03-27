# Development Dockerfile for Frontend
# Supports Vue 3.5.31+, React, Angular, Svelte, or any Node.js-based frontend

FROM node:22-alpine

# Install Git (useful for some npm packages)
RUN apk add --no-cache git

# Set working directory
WORKDIR /app

# Copy package files first (for better caching)
COPY package*.json ./

# Install dependencies
# Uses package-lock.json if available
RUN npm ci || npm install

# Expose port for dev server
# Vite uses 5173, React/Next.js use 3000, Angular uses 4200
# We'll use 5173 as default but it can be changed
EXPOSE 5173

# Set environment variables for development
ENV NODE_ENV=development
ENV HOST=0.0.0.0
ENV PORT=5173

# Start development server
# The command can be overridden for different frameworks:
# - Vue/Vite: npm run dev -- --host 0.0.0.0
# - React/Next.js: npm run dev
# - Angular: npm start -- --host 0.0.0.0 --disable-host-check
# - SvelteKit: npm run dev -- --host
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
