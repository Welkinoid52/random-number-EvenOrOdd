FROM node:18-slim
WORKDIR /app
COPY client-service.js .
RUN npm init -y
RUN npm install express axios
CMD ["node", "client-service.js"]
