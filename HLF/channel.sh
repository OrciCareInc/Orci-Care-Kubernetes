#!/bin/sh
export GENESIS_BLOCK=/etc/crypto-config/Orci-Care-Kubernetes/HLF/channel-artifacts/orderer-channel.tx
export POD_ID=`kubectl get pod | grep peer0 | cut -f1 -d' '`
export ORDERER_ADDR="10.100.216.145"
export ORG_DOMAIN="org2.example.com"

echo "POD_ID: " $POD_ID

kubectl exec $POD_ID -it -- bash -c "CORE_PEER_MSPCONFIGPATH=/etc/crypto-config/Orci-Care-Kubernetes/HLF/crypto-config/peerOrganizations/$ORG_DOMAIN/users/Admin@$ORG_DOMAIN/msp && CORE_PEER_ADDRESS=0.0.0.0:7051 peer channel create -o $ORDERER_ADDR:7050 -c mychannel -f $GENESIS_BLOCK"

#kubectl exec $POD_ID -it /bin/bash -c "CORE_PEER_MSPCONFIGPATH=/etc/crypto-config/Orci-Care-Kubernetes/HLF/crypto-config/peerOrganizations/$ORG_DOMAIN/users/Admin@$ORG_DOMAIN/msp && CORE_PEER_ADDRESS=0.0.0.0:7051 && peer channel join -b mychannel.block -o $ORDERER_ADDR:7050"
