helm delete test

helm del --purge test

sleep 2

export ORDERER_PVC_ID=`kubectl get pvc | grep orderer | cut -f1 -d' '`
kubectl delete pvc $ORDERER_PVC_ID

echo "***** PVC LIST ******"
kubectl get pvc

echo "***** PV LIST ******"
kubectl get pv

sleep 2

helm install --name test ./fabric-artifacts -f org1.example.com.yaml
