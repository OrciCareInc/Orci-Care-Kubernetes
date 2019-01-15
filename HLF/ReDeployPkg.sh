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

echo "sleeping for 90 sec....."
sleep 90

export COUCHDB0_POD_ID=`kubectl get po | grep couchdb0 | cut -f1 -d' '`
export COUCHDB1_POD_ID=`kubectl get po | grep couchdb1 | cut -f1 -d' '`

echo "Creating DBs in CouchDB0"
kubectl exec -it $COUCHDB0_POD_ID -- bash -c "curl -X PUT http://CouchOrci0:CouchOrciDB00@127.0.0.1:5984/_users"
kubectl exec -it $COUCHDB0_POD_ID -- bash -c "curl -X PUT http://CouchOrci0:CouchOrciDB00@127.0.0.1:5984/_replicator"
kubectl exec -it $COUCHDB0_POD_ID -- bash -c "curl -X PUT http://CouchOrci0:CouchOrciDB00@127.0.0.1:5984/_global_changes"
echo "Creating DBs in CouchDB1"
kubectl exec -it $COUCHDB1_POD_ID -- bash -c "curl -X PUT http://CouchOrci1:CouchOrciDB01@127.0.0.1:5984/_users"
kubectl exec -it $COUCHDB1_POD_ID -- bash -c "curl -X PUT http://CouchOrci1:CouchOrciDB01@127.0.0.1:5984/_replicator"
kubectl exec -it $COUCHDB1_POD_ID -- bash -c "curl -X PUT http://CouchOrci1:CouchOrciDB01@127.0.0.1:5984/_global_changes"
