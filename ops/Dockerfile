# ===============================
# 1. Base image
# ===============================
FROM node:20-alpine AS base
WORKDIR /app

# ===============================
# 2. Dependencies
# ===============================
FROM base AS deps
COPY package.json package-lock.json ./
RUN npm ci

# ===============================
# 3. Build
# ===============================
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# ===============================
# 4. Production runner
# ===============================
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Create non-root user
RUN addgroup -g 1001 -S nodejs \
  && adduser -S nextjs -u 1001

# Copy standalone output
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# Permissions
RUN chown -R nextjs:nodejs /app

USER nextjs

EXPOSE 3000

CMD ["node", "server.js"]
