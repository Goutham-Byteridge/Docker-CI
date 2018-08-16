#Download a node image for building nodejs application
FROM node:9.5.0-alpine
RUN mkdir app
ADD . /app
WORKDIR /app
RUN npm install && rm -rf ~/.npm
RUN npm test
#Specify the port number on which the application should run
EXPOSE 1337
CMD ["npm", "start"]