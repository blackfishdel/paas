#/bin/bash -ex

#username=zkp
#password=zhongkejf

#1
#生成CA证书
#mkdir -p  ~/docker-registry && openssl req \
#   -subj "/CN=zkpregistry.com/" -newkey rsa:4096 -nodes -sha256 -keyout ~/docker-registry/domain.key \
#   -x509 -days 365 -out ~/docker-registry/domain.crt

#2
#生成密码文件
#docker run --rm --entrypoint htpasswd registry:2.6.0 -bn ${username} ${password} > ~/docker-registry/nginx.htpasswd

docker stop nginx && docker rm -v nginx
docker stop registry && docker rm -v registry
#3
#运行registry
docker run -d -p 5000:5000 --restart=always --name registry \
  -v ~/docker-registry/data:/var/lib/registry \
  -v ~/docker-registry/config.yml:/etc/docker/registry/config.yml \
  registry:2.6.0

#4
#运行nginx
docker run -d -p 5043:443 --name nginx \
  -v ~/docker-registry:/etc/nginx/conf.d \
  -v ~/docker-registry/nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx:1.11.10
