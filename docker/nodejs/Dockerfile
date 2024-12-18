# Use an ARG to define the Node.js version to make it easily updatable
ARG NODE_VERSION=23.4.0

# Base image
FROM node:${NODE_VERSION}-alpine

RUN rm -rf /var/cache/apk/*
RUN apk --no-cache --virtual build-dependencies add python3 make g++
RUN apk del build-dependencies


#Defining the user to avoid permission on shared volumes
USER node

RUN npm rebuild node-sass --force
#RUN npm install
#COPY . $SERVER_HOME
#EXPOSE 5000
#CMD npm run build