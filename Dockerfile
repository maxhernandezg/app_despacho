# ---------- Base ----------
FROM node:20-alpine AS base
WORKDIR /app
COPY package.json package-lock.json ./

# ---------- Dependencias (incluye dev) ----------
FROM base AS deps
RUN npm ci

# ---------- Dev ----------
# docker build --target dev -t despacho:dev .
# docker run --rm -p 5173:5173 -v "$PWD":/app -v /app/node_modules despacho:dev
FROM deps AS dev
ENV NODE_ENV=development
COPY . .
EXPOSE 5173
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "5173"]

# ---------- Build ----------
FROM deps AS build
ENV NODE_ENV=production
COPY . .
RUN npm run build

# ---------- Prod ----------
# docker build --target prod -t despacho:prod .
# docker run --rm -p 8080:80 despacho:prod
FROM nginx:1.27-alpine AS prod
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
