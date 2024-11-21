# Build stage
FROM node:14 as builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with legacy peer deps flag due to Angular 6.x
RUN npm install --legacy-peer-deps

# Install global Angular CLI matching project version
RUN npm install -g @angular/cli@6.2.5

# Copy project files
COPY . .

# Build the application
# Adding --no-progress to reduce log output
RUN npm run build -- --no-progress

# Production stage
FROM nginx:alpine

# Copy built assets from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 8080 (Cloud Run requirement)
EXPOSE 8080

# Update nginx configuration to listen on port 8080
RUN sed -i.bak 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf

# Start nginx
CMD ["nginx", "-g", "daemon off;"]