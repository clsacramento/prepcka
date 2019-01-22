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


## Generating the CA
Use step 2 from kubernetes.io doc:
```
mkdir cert
cd cert
cfssl print-defaults config > ca-config.json
cfssl print-defaults csr > ca-csr.json
```
