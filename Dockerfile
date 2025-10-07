# Base image
FROM node:18

# Set working directory
WORKDIR /wiki

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the project
COPY . .

# Expose port (Wiki.js default)
EXPOSE 3000

# Start Wiki.js
CMD ["node", "server"]
