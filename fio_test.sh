#!/bin/bash

#sudo yum install fio -y

export disk=$1
export testtype=$2

case $disk in 
	"ssd")

	TEMP_DIR=$(mount | grep sdb1 | awk '{print $3}')/fiotest 
	;;

	"nvme")
	if [[ ! -d /mnt/resource_nvme && -e /dev/nvme0n1 ]];then
	    sudo mkfs.ext4 /dev/nvme0n1
	    sudo mkdir -p /mnt/resource_nvme
	    sudo mount /dev/nvme0n1 /mnt/resource_nvme
	    sudo chmod 775 /dev/nvme0n1
	    sudo chmod 777 /mnt/resource_nvme/
	fi
	TEMP_DIR=$(mount | grep nvme | awk '{print $3}')/fiotest
	;;

	*)
	exit 1
esac


TEMP_DIR=$(mount | grep sdb1 | awk '{print $3}')/fiotest 
mkdir -p $TEMP_DIR

rm $TEMP_DIR/*

if [ $testtype == "quick" ]
then
	echo FIOWriteTPT: $(fio --name=write_throughput --directory=$TEMP_DIR --numjobs=4 --size=2G --time_based --runtime=60s --ramp_time=2s --ioengine=libaio --direct=1 --verify=0 --bs=4M --iodepth=128 --rw=write --group_reporting=1 | grep "WRITE:" | awk '{print $2}' | cut -d '=' -f2 | cut -d 'M' -f1) MiB/s | tee fio-$(hostname  | tr "[:upper:]" "[:lower:]")-$testtype-$disk.log 

	rm $TEMP_DIR/*

elif [ $testtype == "complete" ]
then

	echo FIOWriteTPT: $(fio --name=write_throughput --directory=$TEMP_DIR --numjobs=16 --size=10G --time_based --runtime=120s --ramp_time=2s --ioengine=libaio --direct=1 --verify=0 --bs=1M --iodepth=64 --rw=write --group_reporting=1 | grep "WRITE:" | awk '{print $2}' | cut -d '=' -f2 | cut -d 'M' -f1) MiB/s | tee fio-$(hostname  | tr "[:upper:]" "[:lower:]")-$testtype-$disk.log 

	rm $TEMP_DIR/*

	echo FIOWriteIOPS: $(fio --name=write_iops --directory=$TEMP_DIR --size=2G --numjobs=2 --time_based --runtime=300s --ramp_time=2s --ioengine=libaio --direct=1 --verify=0 --bs=4K --iodepth=128 --rw=randwrite --group_reporting=1 | grep "write: IOPS=" | awk '{print $2}' | cut -d '=' -f2 | cut -d 'k' -f1) K | tee -a fio-$(hostname  | tr "[:upper:]" "[:lower:]")-$testtype-$disk.log

	rm $TEMP_DIR/*

	echo FIOReadTPT: $(fio --name=read_throughput --directory=$TEMP_DIR --numjobs=16 --size=10G --time_based --runtime=120s --ramp_time=2s --ioengine=libaio --direct=1 --verify=0 --bs=1M --iodepth=64 --rw=read --group_reporting=1  | grep "READ:" | awk '{print $2}' | cut -d '=' -f2 | cut -d 'M' -f1) MiB/s | tee -a fio-$(hostname | tr "[:upper:]" "[:lower:]")-$testtype-$disk.log

	rm $TEMP_DIR/*

	echo FIOReadIOPS: $(fio --name=read_iops --directory=$TEMP_DIR --size=2G --numjobs=2 --time_based --runtime=240s --ramp_time=2s --ioengine=libaio --direct=1 --verify=0 --bs=4K --iodepth=128 --rw=randread --group_reporting=1 | grep "read: IOPS=" | awk '{print $2}' | cut -d '=' -f2 | cut -d 'k' -f1) K | tee -a fio-$(hostname | tr "[:upper:]" "[:lower:]")-$testtype-$disk.log

	rm $TEMP_DIR/*

else
	echo "Not a proper Test Type!"
fi

