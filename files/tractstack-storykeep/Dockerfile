# Stage 1: Build stage
FROM node:20-slim AS build
WORKDIR /app
# Install necessary dependencies for building the application
RUN apt-get update && \
    apt-get install -y openssl python3 make g++ && \
    rm -rf /var/lib/apt/lists/*
# Install pnpm globally
RUN corepack enable && corepack prepare pnpm@9.15.4 --activate
# Copy package files
COPY package.json pnpm-lock.yaml ./
# Install dependencies
RUN pnpm install --frozen-lockfile
# Copy the rest of the application files
COPY . .
# Create config directory
RUN mkdir -p /app/config
# Generate SSL certificates
RUN openssl genrsa -des3 -passout pass:x -out server.pass.key 2048 && \
    openssl rsa -passin pass:x -in server.pass.key -out server.key && \
    rm server.pass.key && \
    echo "[req]\ndistinguished_name=req_distinguished_name\nreq_extensions=v3_req\n[req_distinguished_name]\n[v3_req]\nsubjectAltName=DNS:ZZZZQ,DNS:*.ZZZZQ" > san.cnf && \
    openssl req -new -key server.key -out server.csr \
        -subj "/C=UK/ST=Ontario/L=Toronto/O=AtRiskMedia/OU=TractStack/CN=ZZZZQ" \
        -config san.cnf && \
    openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt -extfile san.cnf -extensions v3_req && \
    rm san.cnf server.csr
# Build the application
RUN pnpm build
# Stage 2: Runtime stage
FROM node:20-slim AS runtime
WORKDIR /app
# Create necessary directories
RUN mkdir -p /app/config /app/public/styles /app/.tractstack /tenants
# Copy the build artifacts from the build stage
COPY --from=build /app/dist ./dist
COPY --from=build /app/tailwind.config.cjs ./tailwind.config.cjs
COPY --from=build /app/server.key ./server.key
COPY --from=build /app/server.crt ./server.crt
# Create .env file with default values that will be overwritten by mount
RUN touch .env
# Copy only the production dependencies
COPY --from=build /app/node_modules ./node_modules
# Set environment variables and expose port
ENV HOST=0.0.0.0
ENV PORT=ZZZZY
EXPOSE ZZZZY
# Command to run the application
CMD ["node", "./dist/server/entry.mjs"]
