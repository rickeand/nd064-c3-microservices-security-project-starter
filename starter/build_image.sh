docker build . -t rickeand/leap-hardened:latest --no-cache=true
docker push rickeand/leap-hardened:latest
docker run --cpu-shares 512 --security-opt=no-new-privileges rickeand/leap-hardened:latest