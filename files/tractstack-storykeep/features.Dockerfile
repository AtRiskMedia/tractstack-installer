# Stage 1: Build stage
FROM node:20-slim AS build
WORKDIR /app

# Install necessary dependencies for building the application
RUN apt-get update && \
    apt-get install -y openssl python3 make g++ git && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm globally
RUN corepack enable && corepack prepare pnpm@9.12.3 --activate

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Add node_modules/.bin to PATH
ENV PATH=/app/node_modules/.bin:$PATH

# Copy the rest of the application files
COPY . .

# Generate SSL certificates
RUN openssl genrsa -des3 -passout pass:x -out server.pass.key 2048 && \
    openssl rsa -passin pass:x -in server.pass.key -out server.key && \
    rm server.pass.key && \
    openssl req -new -key server.key -out server.csr \
        -subj "/C=UK/ST=Ontario/L=Toronto/O=AtRiskMedia/OU=TractStack/CN=features.ZZZZZ.tractstack.com" && \
    openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

# Verify node_modules before building
RUN ls -la && \
    if [ ! -d "node_modules" ]; then echo "node_modules not found" && exit 1; fi

# Build the application
RUN echo "Starting build process..." && \
    pnpm run build && \
    echo "Build process completed."

# Stage 2: Runtime stage
FROM node:20-slim AS runtime
WORKDIR /app

# Copy the build artifacts from the build stage
COPY --from=build /app/dist ./dist
COPY --from=build /app/server.key ./server.key
COPY --from=build /app/server.crt ./server.crt

# Copy package files and node_modules
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/pnpm-lock.yaml ./pnpm-lock.yaml
COPY --from=build /app/node_modules ./node_modules

# Set environment variables and expose port
ENV HOST=0.0.0.0
ENV PORT=ZZZZY
EXPOSE ZZZZY

# Command to run the application
CMD ["node", "./dist/server/entry.mjs"]
