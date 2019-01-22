type=kubernetes
cat admin-csr.json | sed "s/admin/$type/g" | sed "s/system:masters/system:nodes/g" > $type-csr.json
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
                                --region $(gcloud config get-value compute/region) \
                                --format 'value(address)')
int=""
for i in `seq 1 3` ; do
        INTERNAL_IP=$(gcloud compute instances describe master-$i \
          --format 'value(networkInterfaces[0].networkIP)')
        int=$int,$INTERNAL_IP 
done
gcpips=${KUBERNETES_PUBLIC_ADDRESS}$int
svcip=10.32.0.1
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=$svcip,$gcpips,127.0.0.1,kubernetes.default \
  -profile=kubernetes \
  $type-csr.json | cfssljson -bare $type
