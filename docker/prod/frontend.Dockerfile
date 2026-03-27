# Production Dockerfile for Frontend
# Multi-stage build supporting Vue 3.5.31+, React, Angular, Svelte, etc.

# Build stage
FROM node:22-alpine AS builder

# Install dependencies needed for build
RUN apk add --no-cache git

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies (production only)
RUN npm ci

# Copy source code
COPY . .

# Build the application
# This works for Vue, React, Angular, Svelte, etc.
RUN npm run build

# Production stage - Create a minimal image with the built files
# This can be used to copy files to nginx or serve directly
FROM alpine:latest AS production

WORKDIR /app

# Copy built files from builder
# Most frameworks output to 'dist' (Vue, Vite) or 'build' (React, Angular)
# We'll copy both possibilities
COPY --from=builder /app/dist ./dist 2>/dev/null || true
COPY --from=builder /app/build ./build 2>/dev/null || true

# Create a simple http server for testing (optional)
# In actual deployment, nginx will serve these files directly
RUN apk add --no-cache darkhttpd

EXPOSE 8080

# Default command - serve the built files
# Checks for 'dist' first (Vue/Vite), then 'build' (React/Angular)
CMD ["sh", "-c", "darkhttpd /app/dist --port 8080 2>/dev/null || darkhttpd /app/build --port 8080"]
