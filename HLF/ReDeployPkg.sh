helm delete test 

helm del --purge test

sleep 5

helm install --name test ./fabric-artifacts -f org1.example.com.yaml
