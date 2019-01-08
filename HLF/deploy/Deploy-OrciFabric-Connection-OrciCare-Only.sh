echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo


echo "**Deployment Process Start***"

export ORG1_POD_ID=`kubectl get pod | grep peer0-org1 | cut -f1 -d' '`
export ORG2_POD_ID=`kubectl get pod | grep peer0-org2 | cut -f1 -d' '`

CARDNAME=PeerAdmin@orcicarenet-network-orcicare-only
CONNECTION_FILENAME=/etc/crypto-config/Orci-Care-Kubernetes/HLF/deploy/connection-orcifabric-orcicare-only.json
ORG1_ADMIN_USER_MSP_SIGNCERT_FILENAME=/etc/crypto-config/Orci-Care-Kubernetes/HLF/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem
ORG1_ADMIN_USER_MSP_KEYSTORE_FILENAME_PATH=/etc/crypto-config/Orci-Care-Kubernetes/HLF/crypto-config/peerOrganizations/orcicare.orcifabric.com/users/Admin@orcicare.orcifabric.com/msp/keystore/

TargetFile="$(ls "$ORG1_ADMIN_USER_MSP_KEYSTORE_FILENAME_PATH" -t | head -n1)"
ORG1_ADMIN_USER_MSP_KEYSTORE_FILENAME=$ORG1_ADMIN_USER_MSP_KEYSTORE_FILENAME_PATH$TargetFile

ORCICARE_ADMIN_NAME=ORADMIN1
DEPLOY_FILENAME=/etc/crypto-config/Orci-Care-Kubernetes/HLF/deploy/orcicare-network4@0.0.3.bna
ENDORCEMENT_FILENAME=/etc/crypto-config/Orci-Care-Kubernetes/HLF/deploy/endorsement-policy.json
NETWORK_NAME=orcicare-network4
NETWORK_CARDNAME=$ORCICARE_ADMIN_NAME@$NETWORK_NAME
NETWORK_CARDNAME_FILE=$NETWORK_CARDNAME.card

echo "** Create Composer Card **"
kubectl exec $ORG1_POD_ID -it -- bash -c "composer card create -p $CONNECTION_FILENAME -u PeerAdmin -c $ORG1_ADMIN_USER_MSP_SIGNCERT_FILENAME -k $ORG1_ADMIN_USER_MSP_KEYSTORE_FILENAME -r PeerAdmin -r ChannelAdmin"
sleep 1

echo "** Delete & Import Composer Card **"
composer card delete -c $CARDNAME
composer card import -f $CARDNAME.card
sleep 1

echo "** Composer Network Install **"
composer network install -c $CARDNAME -a $DEPLOY_FILENAME
sleep 1

echo "** Identity Request **"
composer identity request -c $CARDNAME -u admin -s adminpw -d $ORCICARE_ADMIN_NAME


echo "** Starting Business Network with BNA File **"
composer network start -n $NETWORK_NAME -V 0.0.3 -c $CARDNAME -o endorsementPolicyFile=$ENDORCEMENT_FILENAME -A $ORCICARE_ADMIN_NAME -C $ORCICARE_ADMIN_NAME/admin-pub.pem 
sleep 2

echo "** Composer Card Create for Network **"
composer card create -p $CONNECTION_FILENAME -u $ORCICARE_ADMIN_NAME -n $NETWORK_NAME -c $ORCICARE_ADMIN_NAME/admin-pub.pem -k $ORCICARE_ADMIN_NAME/admin-priv.pem

echo "** Delete & Import Network Card **"
composer card delete -c $ORCICARE_ADMIN_NAME@$NETWORK_NAME
composer card import -f $NETWORK_CARDNAME_FILE

echo "** Network PING Test **"
composer network ping -c $NETWORK_CARDNAME

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

exit 0
