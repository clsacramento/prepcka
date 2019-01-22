i=$1
type=$2
subnet=$3
range=$4
gcloud compute instances create $type-${i} \
        --async \
        --boot-disk-size 200GB \
        --image-family ubuntu-1804-lts \
        --image-project ubuntu-os-cloud \
        --machine-type n1-standard-1 \
        --private-network-ip $range${i} \
        --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
        --subnet $subnet \
        --tags kubernetes-the-hard-way,$type
