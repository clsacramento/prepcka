type=$1
i=$2
cat admin-csr.json | sed "s/admin/system:node:$type-$i/g" | sed "s/system:masters/system:nodes/g" > $type-$i-csr.json
EXTERNAL_IP=$(gcloud compute instances describe $type-$i \
          --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')
INTERNAL_IP=$(gcloud compute instances describe $type-$i \
          --format 'value(networkInterfaces[0].networkIP)')
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP} \
  -profile=kubernetes \
  $type-$i-csr.json | cfssljson -bare $type-$i
