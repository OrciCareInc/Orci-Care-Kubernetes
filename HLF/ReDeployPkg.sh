helm delete test 

helm del --purge test

helm install --name test ./fabric-artifacts -f org1.example.com.yaml
