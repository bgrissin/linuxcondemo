#! /bin/sh

# Build and run notary
git clone -b trust-sandbox https://github.com/docker/notary.git
cd notary; docker-compose kill; docker-compose rm -f; docker-compose build && docker-compose up -d
cd ..

# Build and run registry
git clone https://github.com/docker/distribution.git
cp Dockerfile.registry distribution/Dockerfile
cp hack-demo.txt demotamper.sh distribution/
cd distribution; docker build -t registry .
docker kill registry; docker rm registry; docker run -d -p 5000:5000 --name registry registry
cd ..

# Build and push the sandbox
docker build --rm --force-rm -t notarydemo/notarytest .
docker push notarydemo/notarytest

# This stuff is to test with simple alpine instead of dolly
docker build --rm --force-rm -t registry:5000/cirros:latest -f Dockerfile.cirros .
docker push registry:5000/cirros:latest

#docker images | grep cirros | awk '{print $3}' | xargs docker rmi -f
docker run -it -v /var/run/docker.sock:/var/run/docker.sock --link notary_notaryserver_1:notaryserver --link registry:registry diogomonica/notarytest
