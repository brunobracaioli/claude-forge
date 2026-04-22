# =============================================================================
# Dockerfile — Production-GCP preset (multi-stage build, Cloud Run ready)
# [CUSTOMIZE] Adjust base image, build steps, and runtime for your stack.
# =============================================================================

# --- Stage 1: Build ---
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --production=false

COPY . .
RUN npm run build
RUN npm prune --production

# --- Stage 2: Runtime ---
FROM node:20-alpine AS runtime

# Security: non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

WORKDIR /app

COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=builder --chown=appuser:appgroup /app/package.json ./

USER appuser

# Cloud Run passes $PORT (default 8080). Respect it at runtime.
ENV PORT=8080
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD ["wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/health"]

CMD ["node", "dist/index.js"]
