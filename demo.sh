#! /bin/sh

# Build and run notary
git clone -b trust-sandbox https://github.com/docker/notary.git
cd notary; docker-compose kill; docker-compose rm -f; docker-compose build && docker-compose up -d
cd ..

# Build and run registry
git clone https://github.com/docker/distribution.git
cp Dockerfile.registry distribution/Dockerfile
cp hack-dolly.txt hack-demo.txt demotamper.sh dollytamper.sh distribution/
cd distribution; docker build -t registry .
docker kill registry; docker rm registry; docker run -d -p 5000:5000 --name registry registry
cd ..

# Build and push the sandbox
docker build --rm --force-rm -t diogomonica/notarytest .
#docker push diogomonica/notarytest

# This stuff is to test with simple alpine instead of dolly
docker build --rm --force-rm -t registry:5000/demo -f Dockerfile.alpine .
docker build --rm --force-rm -t registry:5000/demo_malicious -f Dockerfile_malicious.alpine .
docker push registry:5000/demo_malicious
docker push registry:5000/demo
docker images | grep demo | awk '{print $3}' | xargs docker rmi -f

# Build and push dolly and malicious dolly
#docker build --rm --force-rm -t registry:5000/dolly -f Dockerfile.nginx .
#docker push registry:5000/dolly
#docker build --rm --force-rm -t registry:5000/dolly_malicious -f Dockerfile_malicious.nginx .
#docker push registry:5000/dolly_malicious

#docker images | grep dolly | awk '{print $3}' | xargs docker rmi -f
docker run -it -v /var/run/docker.sock:/var/run/docker.sock --link notary_notaryserver_1:notaryserver --link registry:registry diogomonica/notarytest
