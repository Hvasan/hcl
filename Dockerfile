# Use an official Node.js runtime as a parent image
FROM node:18-alpine

# Set the working directory to /app
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install any dependencies
RUN npm install --production

# Copy the source code to the working directory
COPY . .

# Expose the port the app listens on
EXPOSE 3000

# Define the command to run the application
CMD [ "node", "server.js" ]