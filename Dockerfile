############################################
# WebCurl
############################################
FROM golang:1.24.4-alpine3.22 AS build-env
WORKDIR /mnt
COPY . /mnt/
RUN echo 'start build'
RUN cd /mnt/ && export GO111MODULE=on && CGO_ENABLED=0 go build -o WebCurl

FROM alpine:3.22
RUN apk update \
	&& apk add --no-cache tzdata \
	&& cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime \
	&& mkdir -p /usr/local/WebCurl
COPY --from=build-env /mnt/WebCurl /usr/local/WebCurl
WORKDIR /usr/local/WebCurl
EXPOSE 4444
CMD [ "/usr/local/WebCurl/WebCurl" ]
############################################

# build
# docker build -t webcurl:2.2 .

# start
# docker run -d -p:4444:4444 --name webcurl  webcurl:2.2
# docker run -d --name webcurl -p 4444:4444 -v /usr/share/nginx/html/:/usr/local/WebCurl/webroot webcurl:2.2 /usr/local/WebCurl/WebCurl --webroot=/usr/local/WebCurl/webroot
