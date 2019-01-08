#!/bin/sh

echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo

echo "** Channel Creation Start ***"

export GENESIS_BLOCK=/etc/crypto-config/Orci-Care-Kubernetes/HLF/channel-artifacts/orderer-channel.tx
export ORG1_POD_ID=`kubectl get pod | grep peer0-org1 | cut -f1 -d' '`
export ORG2_POD_ID=`kubectl get pod | grep peer0-org2 | cut -f1 -d' '`
export ORDERER_ADDR="orderer.example.com"
export ORDERER_MSPID="OrdererMSP"
export ORG1_DOMAIN="org1.example.com"
export ORG2_DOMAIN="org2.example.com"
export ORG1_CORE_PEER_ADDRESS="peer0.org1.example.com:7051"
export ORG2_CORE_PEER_ADDRESS="peer0.org2.example.com:7051"
export ORG1_CORE_PEER_LOCALMSPID="Org1MSP"
export ORG2_CORE_PEER_LOCALMSPID="Org2MSP"
export ORDER_CA=/etc/crypto-config/Orci-Care-Kubernetes/HLF/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

echo "ORG1_POD_ID: " $ORG1_POD_ID
echo "ORG2_POD_ID: " $ORG2_POD_ID

kubectl exec $ORG1_POD_ID -it -- bash -c "CORE_PEER_MSPCONFIGPATH=/etc/crypto-config/Orci-Care-Kubernetes/HLF/crypto-config/peerOrganizations/$ORG1_DOMAIN/users/Admin@$ORG1_DOMAIN/msp && CORE_PEER_ADDRESS=$ORG1_CORE_PEER_ADDRESS && CORE_PEER_LOCALMSPID=$ORG1_CORE_PEER_LOCALMSPID && peer channel create -o $ORDERER_ADDR:7050 -c mychannel -f $GENESIS_BLOCK --tls --cafile $ORDER_CA"

echo "** Channel Creation Done ***"

kubectl exec $ORG1_POD_ID -it -- bash -c "CORE_PEER_MSPCONFIGPATH=/etc/crypto-config/Orci-Care-Kubernetes/HLF/crypto-config/peerOrganizations/$ORG1_DOMAIN/users/Admin@$ORG1_DOMAIN/msp && CORE_PEER_ADDRESS=$ORG1_CORE_PEER_ADDRESS && CORE_PEER_LOCALMSPID=$ORG1_CORE_PEER_LOCALMSPID && peer channel join -b mychannel.block -o $ORDERER_ADDR:7050 --tls --cafile $ORDER_CA"

echo "** Peer0 Org1 Joined Channel ***"

kubectl exec $ORG2_POD_ID -it -- bash -c "CORE_PEER_MSPCONFIGPATH=/etc/crypto-config/Orci-Care-Kubernetes/HLF/crypto-config/peerOrganizations/$ORG2_DOMAIN/users/Admin@$ORG2_DOMAIN/msp && CORE_PEER_ADDRESS=$ORG2_CORE_PEER_ADDRESS && CORE_PEER_LOCALMSPID=$ORG2_CORE_PEER_LOCALMSPID && peer channel fetch 0 -o $ORDERER_ADDR:7050 -c mychannel --tls --cafile $ORDER_CA>>mychannel_genesis.block"

kubectl exec $ORG2_POD_ID -it -- bash -c "CORE_PEER_MSPCONFIGPATH=/etc/crypto-config/Orci-Care-Kubernetes/HLF/crypto-config/peerOrganizations/$ORG2_DOMAIN/users/Admin@$ORG2_DOMAIN/msp && CORE_PEER_ADDRESS=$ORG2_CORE_PEER_ADDRESS && CORE_PEER_LOCALMSPID=$ORG2_CORE_PEER_LOCALMSPID && peer channel join -b mychannel_0.block -o $ORDERER_ADDR:7050 --tls --cafile $ORDER_CA"

echo "** Peer0 Org2 Joined Channel ***"


echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

exit 0