# syntax=docker/dockerfile:1

# Build stage
FROM node:22-alpine as build

WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install pnpm and dependencies
RUN npm install -g pnpm@10.4.1 \
    && pnpm install

# Copy frontend source
COPY . .

# Build the React app
RUN pnpm build

# Production stage - serve with nginx
FROM nginx:alpine

# Copy built files to nginx
COPY --from=build /app/dist /usr/share/nginx/html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create environment substitution script
COPY env-config.sh /docker-entrypoint.d/

# Make the script executable
RUN chmod +x /docker-entrypoint.d/env-config.sh

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
