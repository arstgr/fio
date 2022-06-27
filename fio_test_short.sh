#!/bin/bash

#sudo yum install fio -y

export disk=$1

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
	
mkdir -p $TEMP_DIR

echo FIOWriteTPT: $(fio --name=write_throughput --directory=$TEMP_DIR --numjobs=4 --size=2G --time_based --runtime=60s --ramp_time=2s --ioengine=libaio --direct=1 --verify=0 --bs=4M --iodepth=128 --rw=write --group_reporting=1 | grep "WRITE:" | awk '{print $2}' | cut -d '=' -f2 | cut -d 'M' -f1) MiB/s | tee fio-$(hostname  | tr "[:upper:]" "[:lower:]")-$disk.log 

rm $TEMP_DIR/*

