#!/bin/sh

set -e

export VERSION=1.3.0
export ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')

echo "ARCH:" $ARCH

MARCH=`uname -m`

#FABRIC="$MARCH-$VERSION"

FABRIC=1.3.0
COUCH=0.4.13

BIN="$ARCH-$VERSION"
SLEEP_TIMEOUT=10

echo "FABRIC: " $FABRIC
echo "BIN: " $BIN

REP_URL="https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/${BIN}/hyperledger-fabric-${BIN}.tar.gz"
echo "REP_URL: " $REP_URL

ORG_DOMAIN="org1.example.com"

if [ ! "$(docker images | grep hyperledger/fabric )" ]; then
 docker pull hyperledger/fabric-peer:$FABRIC
 docker pull hyperledger/fabric-ca:$FABRIC
 docker pull hyperledger/fabric-ccenv:$FABRIC
 docker pull hyperledger/fabric-orderer:$FABRIC
 docker pull hyperledger/fabric-couchdb:$COUCH
fi

if [ ! -d "bin" ]; then
    curl $REP_URL | tar xz
fi

sleep $SLEEP_TIMEOUT

./bin/cryptogen generate --config=./crypto-config.yaml

sleep $SLEEP_TIMEOUT

KEYSTORE=`ls ./crypto-config/peerOrganizations/$ORG_DOMAIN/users/Admin@$ORG_DOMAIN/msp/keystore`
echo "KEYSTORE: " $KEYSTORE

#composer identity import \
#-p hlfv1 \
#-u Admin@$ORG_DOMAIN \
#-c ./crypto-config/peerOrganizations/$ORG_DOMAIN/users/Admin@$ORG_DOMAIN/msp/signcerts/Admin@$ORG_DOMAIN-cert.pem \
#-k ./crypto-config/peerOrganizations/$ORG_DOMAIN/users/Admin@$ORG_DOMAIN/msp/keystore/$KEYSTORE

#composer card create \
#	-f Admin@$ORG_DOMAIN.card \
#	-p hlfv1 \
#	-n mynetwork \
#	-s mysecret \
#	-u Admin@$ORG_DOMAIN \
#	-c ./crypto-config/peerOrganizations/$ORG_DOMAIN/users/Admin@$ORG_DOMAIN/msp/signcerts/Admin@$ORG_DOMAIN-cert.pem \
#	-k ./crypto-config/peerOrganizations/$ORG_DOMAIN/users/Admin@$ORG_DOMAIN/msp/keystore/$KEYSTORE \
#	-r PeerAdmin

sleep $SLEEP_TIMEOUT

export FABRIC_CFG_PATH=$PWD

OUTPUT_DIR=$PWD/channel-artifacts

mkdir -p $OUTPUT_DIR

./bin/configtxgen -profile TwoOrgsOrdererGenesis -outputBlock $OUTPUT_DIR/orderer-genesis.block
./bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx $OUTPUT_DIR/orderer-channel.tx -channelID mychannel
./bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate $OUTPUT_DIR/MSPanchors.tx -channelID mychannel -asOrg Org1MSP

echo "... 🙌🏿"
  
