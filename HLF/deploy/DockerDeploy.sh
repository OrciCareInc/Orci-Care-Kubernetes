export DOCKER_ID=`docker ps -a | grep hyperledger-composer | cut -f1 -d' '`

docker stop $DOCKER_ID

docker rm $DOCKER_ID

echo ${COMPOSER_CARD}

docker run \
     -d \
     -e COMPOSER_CARD=${COMPOSER_CARD} \
     -e COMPOSER_NAMESPACES=${COMPOSER_NAMESPACES} \
     -e COMPOSER_AUTHENTICATION=${COMPOSER_AUTHENTICATION} \
     -e COMPOSER_MULTIUSER=${COMPOSER_MULTIUSER} \
     -v ~/.composer:/home/composer/.composer \
     -v /home/ubuntu/kubernetes/OrciCare/BlockChain/HLF/crypto-config:/home/crypto-config \
     --name rest \
     -p 3000:3000 \
     orcicare/hyperledger-composer-rest-server
