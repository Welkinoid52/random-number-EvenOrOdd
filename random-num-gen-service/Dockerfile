FROM node:18-alpine
WORKDIR /app
COPY index.js .
RUN npm init -y
RUN npm install express
CMD ["node", "index.js"]
