FROM node:20

# Set working directory
WORKDIR /wiki

# Copy package.json and package-lock.json first
COPY package*.json ./

# Install dependencies with legacy-peer-deps
RUN npm install --legacy-peer-deps --verbose
RUN mkdir -p /wiki/assets

# Copy the rest of the app
COPY . .

# Expose default port
EXPOSE 3000

# Start the app
CMD ["node", "server"]

