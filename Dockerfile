FROM golang:1.12 AS backend-build

WORKDIR /go/src/app
COPY ./backend .

ENV GO111MODULE on
ENV GOPROXY https://goproxy.io

RUN go install -v ./...

FROM node:8.16.0-alpine AS frontend-build

ADD ./frontend /app
WORKDIR /app

# install frontend
RUN npm config set unsafe-perm true
RUN npm install -g yarn && yarn install

RUN npm run build:prod

# images
FROM ubuntu:latest

# set as non-interactive
ENV DEBIAN_FRONTEND noninteractive

# set CRAWLAB_IS_DOCKER
ENV CRAWLAB_IS_DOCKER Y

# install packages
RUN chmod 777 /tmp \
	&& apt-get update \
	&& apt-get install -y curl git net-tools iputils-ping ntp ntpdate python3 python3-pip nginx wget \
	&& ln -s /usr/bin/pip3 /usr/local/bin/pip \
	&& ln -s /usr/bin/python3 /usr/local/bin/python

# install dumb-init
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64
RUN chmod +x /usr/local/bin/dumb-init

# install backend
RUN pip install scrapy pymongo bs4 requests crawlab-sdk scrapy-splash

# add files
ADD . /app

# copy backend files
RUN mkdir -p /opt/bin
COPY --from=backend-build /go/bin/crawlab /opt/bin
RUN cp /opt/bin/crawlab /usr/local/bin/crawlab-server

# copy frontend files
COPY --from=frontend-build /app/dist /app/dist

# copy nginx config files
COPY ./nginx/crawlab.conf /etc/nginx/conf.d

# working directory
WORKDIR /app/backend

# timezone environment
ENV TZ Asia/Shanghai

# language environment
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# frontend port
EXPOSE 8080

# backend port
EXPOSE 8000

# start backend
CMD ["/bin/bash", "/app/docker_init.sh"]
