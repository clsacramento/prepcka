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
### and others
```
bash convertcsr.sh kube-proxy
bash convertcsr.sh kube-scheduler
```
## Generating API Server certificates
Generate
```
bash apiservercert.sh 
```
Files
```
$ ls
admin.csr         ca-csr.json                       kube-controller-manager.pem  kubernetes-key.pem       worker-1.csr       worker-2.pem
admin-csr.json    ca-key.pem                        kube-proxy.csr               kubernetes.pem           worker-1-csr.json  worker-3.csr
admin-key.pem     ca.pem                            kube-proxy-csr.json          kube-scheduler.csr       worker-1-key.pem   worker-3-csr.json
admin.pem         convertcsr.sh                     kube-proxy-key.pem           kube-scheduler-csr.json  worker-1.pem       worker-3-key.pem
apiservercert.sh  kube-controller-manager.csr       kube-proxy.pem               kube-scheduler-key.pem   worker-2.csr       worker-3.pem
ca-config.json    kube-controller-manager-csr.json  kubernetes.csr               kube-scheduler.pem       worker-2-csr.json
ca.csr            kube-controller-manager-key.pem   kubernetes-csr.json          vmcert.sh                worker-2-key.pem
```
Check with openssl
```
openssl x509 -in kubernetes.pem -text
```

## Service accounts certs
Generate
```
bash svcaccountgen.sh 
```
Files
```
$ ls
admin.csr         ca-key.pem                        kube-proxy-csr.json  kube-scheduler-csr.json    vmcert.sh          worker-2.pem
admin-csr.json    ca.pem                            kube-proxy-key.pem   kube-scheduler-key.pem     worker-1.csr       worker-3.csr
admin-key.pem     convertcsr.sh                     kube-proxy.pem       kube-scheduler.pem         worker-1-csr.json  worker-3-csr.json
admin.pem         kube-controller-manager.csr       kubernetes.csr       service-accounts.csr       worker-1-key.pem   worker-3-key.pem
apiservercert.sh  kube-controller-manager-csr.json  kubernetes-csr.json  service-accounts-csr.json  worker-1.pem       worker-3.pem
ca-config.json    kube-controller-manager-key.pem   kubernetes-key.pem   service-accounts-key.pem   worker-2.csr
ca.csr            kube-controller-manager.pem       kubernetes.pem       service-accounts.pem       worker-2-csr.json
ca-csr.json       kube-proxy.csr                    kube-scheduler.csr   svcaccountgen.sh           worker-2-key.pem
```

# Copy certs to VMs
Run
```
bash copycerts.sh
```
Output:
```
$ bash copycerts.sh 
Warning: Permanently added 'compute.2468593225064682962' (ECDSA) to the list of known hosts.
ca.pem                                                                                                                           100% 1371     1.9MB/s   00:00    
worker-1-key.pem                                                                                                                 100% 1679     2.6MB/s   00:00    
worker-1.pem                                                                                                                     100% 1480     2.2MB/s   00:00    
Warning: Permanently added 'compute.2031701244680770991' (ECDSA) to the list of known hosts.
ca.pem                                                                                                                           100% 1371     1.9MB/s   00:00    
worker-2-key.pem                                                                                                                 100% 1679     2.0MB/s   00:00    
worker-2.pem                                                                                                                     100% 1480     2.1MB/s   00:00    
Warning: Permanently added 'compute.1750408361698563500' (ECDSA) to the list of known hosts.
ca.pem                                                                                                                           100% 1371     2.2MB/s   00:00    
worker-3-key.pem                                                                                                                 100% 1679     2.6MB/s   00:00    
worker-3.pem      
ca.pem                                                                                                                           100% 1371     1.7MB/s   00:00    
ca-key.pem                                                                                                                       100% 1679     2.3MB/s   00:00    
kubernetes-key.pem                                                                                                               100% 1679     2.4MB/s   00:00    
kubernetes.pem                                                                                                                   100% 1521     2.7MB/s   00:00    
service-accounts.pem                                                                                                             100% 1444     2.3MB/s   00:00    
Warning: Permanently added 'compute.1840337443504166360' (ECDSA) to the list of known hosts.
ca.pem                                                                                                                           100% 1371     1.8MB/s   00:00    
ca-key.pem                                                                                                                       100% 1679     2.8MB/s   00:00    
kubernetes-key.pem                                                                                                               100% 1679     2.5MB/s   00:00    
kubernetes.pem                                                                                                                   100% 1521     2.3MB/s   00:00    
service-accounts.pem                                                                                                             100% 1444     2.1MB/s   00:00    
Warning: Permanently added 'compute.8204676641925535188' (ECDSA) to the list of known hosts.
ca.pem                                                                                                                           100% 1371     1.8MB/s   00:00    
ca-key.pem                                                                                                                       100% 1679     2.4MB/s   00:00    
kubernetes-key.pem                                                                                                               100% 1679     2.7MB/s   00:00    
kubernetes.pem                                                                                                                   100% 1521     2.5MB/s   00:00    
service-accounts.pem  
```
