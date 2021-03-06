cn=$1
cat admin-csr.json | sed "s/admin/system:$cn/g" | sed "s/system:masters/system:$cn/g" > $cn-csr.json
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes $cn-csr.json | cfssljson -bare $cn
