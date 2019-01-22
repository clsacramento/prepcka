num_masters=$1
num_workers=$2

subnet="peer-subnet"
master_range="192.168.1.1"
worker_range="192.168.1.2"

echo Deploying vms for k8s cluster on subnet $subnet

echo Creating $i master VMs:
for i in `seq 1 $num_masters` ; do
        echo deploying master $i
        bash newhost.sh $i master $subnet $master_range
done

echo Creating $i worker VMs: 
for i in `seq 1 $num_workers` ; do
        echo deploying worker $i 
        bash newhost.sh $i worker $subnet $worker_range
done
