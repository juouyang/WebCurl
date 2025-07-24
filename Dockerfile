############################################
# WebCurl
############################################
FROM golang:1.24.4-alpine3.22 AS build-env
ARG GOPROXY=https://goproxy.cn
ENV GOPROXY=$GOPROXY
WORKDIR /mnt
COPY . /mnt/
RUN echo 'start build'
RUN echo "GOPROXY=$GOPROXY" && \
  cd /mnt/ && export GO111MODULE=on && export GOPROXY="${GOPROXY}" && CGO_ENABLED=0 go build -o WebCurl

FROM alpine:3.22
ARG TZ=Asia/Shanghai
ARG USE_ALIYUN_MIRROR=true
ENV TZ=$TZ
RUN echo "USE_ALIYUN_MIRROR=$USE_ALIYUN_MIRROR" && \
	if [ "$USE_ALIYUN_MIRROR" = "true" ]; then \
      sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \
    fi \
	&& apk update \
	&& apk add --no-cache tzdata \
	&& echo "TZ=$TZ" \
	&& cp /usr/share/zoneinfo/${TZ} /etc/localtime \
 	&& echo "${TZ}" > /etc/timezone \
	&& mkdir -p /usr/local/WebCurl
COPY --from=build-env /mnt/WebCurl /usr/local/WebCurl
WORKDIR /usr/local/WebCurl
EXPOSE 4444
CMD [ "/usr/local/WebCurl/WebCurl" ]
############################################

# 🔧 Build image (default: TZ=Asia/Shanghai, GOPROXY=https://goproxy.cn, USE_ALIYUN_MIRROR=true)
# docker build -t webcurl:2.2 .

# 🔧 Build image with custom arguments:
# docker build -t webcurl:2.2 \
#   --build-arg TZ=Asia/Taipei \
#   --build-arg USE_ALIYUN_MIRROR=false \
#   --build-arg GOPROXY=https://proxy.golang.org \
#   --progress=plain \
#   .

# ▶️ Start container (basic usage)
# docker run -d -p 4444:4444 --name webcurl webcurl:2.2

# ▶️ Start with volume-mounted webroot
# docker run -d --name webcurl \
#   -p 4444:4444 \
#   -v /usr/share/nginx/html/:/usr/local/WebCurl/webroot \
#   webcurl:2.2 \
#   /usr/local/WebCurl/WebCurl --webroot=/usr/local/WebCurl/webroot