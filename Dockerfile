FROM ubuntu:14.04 


ADD docker-1.8.1 /usr/bin/docker
RUN chmod +x /usr/bin/docker \
  && apt-get update \
  && apt-get install -y \
  tree \
  vim \
  git \
  netcat \
  ca-certificates \
  --no-install-recommends


WORKDIR /root
RUN git clone -b trust-sandbox https://github.com/docker/notary.git
RUN cp /root/notary/fixtures/root-ca.crt /usr/local/share/ca-certificates/root-ca.crt
RUN update-ca-certificates

RUN echo "export DOCKER_CONTENT_TRUST_SERVER=https://notaryserver:4443" >> ~/.bashrc
RUN echo "export DOCKER_CONTENT_TRUST_OFFLINE_PASSPHRASE=randompassphrase" >> ~/.bashrc

RUN echo "docker images | grep demo | awk '{print \$3}' | xargs docker rmi -f 2&>/dev/null; clear" > /usr/bin/clean
RUN echo "docker images | grep dolly | awk '{print \$3}' | xargs docker rmi -f 2&>/dev/null; clear" >> /usr/bin/clean
RUN chmod +x /usr/bin/clean

ENTRYPOINT ["bash"]

