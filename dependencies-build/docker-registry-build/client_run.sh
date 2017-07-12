#/bin/bash -ex

echo "180.169.26.102	zkpregistry.com" >> /etc/hosts

#Docker client仍然在使用身份验证时证书验证不通过？
#使用身份验证时，某些版本的Docker还需要您在操作系统级别信任证书。通常，在Ubuntu上，这是通过：
cp /home/delxie/下载/domain.crt /usr/local/share/ca-certificates/zkpregistry.com.crt
update-ca-certificates

#..和红帽（及其衍生品）上：
cp certs/domain.crt /etc/pki/ca-trust/source/anchors/zkpregistry.com.crt
update-ca-trust

#...在某些发行版（例如Oracle Linux 6）上，需要手动启用共享系统证书功能：
#$ update-ca-trust enable

#现在重新启动docker（service docker stop && service docker start或任何其他方式，你用来重新启动docker）。
service docker stop && service docker start

docker login -u=zkp -p=zhongkejf -e=ci@zhongkejf.com zkpregistry.com:5043

docker login -u=zkp -p=zhongkejf zkpregistry.com:5043
docker tag ubuntu zkpregistry.com:5043/test
docker push zkpregistry.com:5043/test
docker pull zkpregistry.com:5043/test