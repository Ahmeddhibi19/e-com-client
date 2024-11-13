# Stage 1: Build the Angular application
FROM node:16 AS builder

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json to install dependencies
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the Angular project files to the container
COPY . .

# Build the Angular app in production mode
RUN npm run build -- --configuration production

# Stage 2: Serve the app with nginx
FROM nginx:alpine

# Copy the build output to nginx's html folder
COPY --from=builder /app/dist/angular-ecommerce /usr/share/nginx/html

# Copy SSL certificates for localhost
COPY ssl-localhost/localhost.crt /etc/ssl/certs/localhost.crt
COPY ssl-localhost/localhost.key /etc/ssl/private/localhost.key

# Copy a custom nginx configuration file to enable HTTPS
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 443 for HTTPS
EXPOSE 443

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
