# Generating certificates for the cluster

## with cfssl

### hard way guide:
https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md

### kubernetes.io equivalent
https://kubernetes.io/docs/concepts/cluster-administration/certificates/#cfssl


### How to generate the config files during the exam
Since we cannot copy the files directly form the doc, use cfssl print-defaults to generate the files than modify them

Command:
```
$ cfssl print-defaults list
Default configurations are available for:
        config
        csr       
```

Genereate config default:
```
$ cfssl print-defaults config
{
    "signing": {
        "default": {
            "expiry": "168h"
        },
        "profiles": {
            "www": {
                "expiry": "8760h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            },
            "client": {
                "expiry": "8760h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "client auth"
                ]
            }
        }
    }
}
```
Generate csr default:
```
$ cfssl print-defaults csr
{
    "CN": "example.net",
    "hosts": [
        "example.net",
        "www.example.net"
    ],
    "key": {
        "algo": "ecdsa",
        "size": 256
    },
    "names": [
        {
            "C": "US",
            "L": "CA",
            "ST": "San Francisco"
        }
    ]
}
```


## Generating the CA root cert
Use step 2 from kubernetes.io doc:
```
mkdir cert
cd cert
cfssl print-defaults config > ca-config.json
cfssl print-defaults csr > ca-csr.json
```
Update files then run:
```
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
```

Files created:
```
$ ls
ca-config.json  ca.csr  ca-csr.json  ca-key.pem  ca.pem
```

## Generate admin certs
Create admin-csr.json from ca-csr.json
```
$ cp ca-csr.json admin-csr.json
$ diff ca-csr.json admin-csr.json 
2c2
<     "CN": "kubernetes",
---
>     "CN": "admin",
12,13c12,13
<           "O": "CA",
<           "OU": "Kubernetes"
---
>           "O": "system:masters",
>           "OU": "Kubernetes install"
```
Generate using the previously created ca:
```
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin
```

Files generated:
```
$ ls
admin.csr  admin-csr.json  admin-key.pem  admin.pem  ca-config.json  ca.csr  ca-csr.json  ca-key.pem  ca.pem
```
## Generate kubelets client certs
```
for i in `seq 1 3` ; do
    bash vmcerts.sh worker $i
done
```
TODO: link to vmcerts.sh

Final files created:
```
$ ls
admin.csr       admin.pem       ca-csr.json  vmcert.sh          worker-1-key.pem  worker-2-csr.json  worker-3.csr       worker-3.pem
admin-csr.json  ca-config.json  ca-key.pem   worker-1.csr       worker-1.pem      worker-2-key.pem   worker-3-csr.json
admin-key.pem   ca.csr          ca.pem       worker-1-csr.json  worker-2.csr      worker-2.pem       worker-3-key.pem
```

Use openssl to check if the final .pem for the workers are correct (specially the IPs):
```
openssl x509 -in worker-1.pem -text
```

## Controller Manager Client Certificate
Run:
```
bash convertcsr.sh kube-controller-manager
```
TODO: lik convertcsr.sh

Check with opessnl (optional):
```
openssl x509 -in kube-controller-manager.pem -text
```
Files:
```
$ ls
admin.csr       ca-config.json  ca.pem                            kube-controller-manager-key.pem  worker-1-csr.json  worker-2-csr.json  worker-3-csr.json
admin-csr.json  ca.csr          convertcsr.sh                     kube-controller-manager.pem      worker-1-key.pem   worker-2-key.pem   worker-3-key.pem
admin-key.pem   ca-csr.json     kube-controller-manager.csr       vmcert.sh                        worker-1.pem       worker-2.pem       worker-3.pem
admin.pem       ca-key.pem      kube-controller-manager-csr.json  worker-1.csr                     worker-2.csr       worker-3.csr
```


## Generating API Server certificates
TODO
