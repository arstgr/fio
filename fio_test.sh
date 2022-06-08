#!/bin/bash

#sudo yum install fio -y

TEMP_DIR=$(mount | grep sdb1 | awk '{print $3}')/fiotest 
mkdir -p $TEMP_DIR

rm $TEMP_DIR/*

echo FIOWriteTPT: $(fio --name=write_throughput --directory=$TEMP_DIR --numjobs=16 --size=10G --time_based --runtime=120s --ramp_time=2s --ioengine=libaio --direct=1 --verify=0 --bs=1M --iodepth=64 --rw=write --group_reporting=1 | grep "WRITE:" | awk '{print $2}' | cut -d '=' -f2 | cut -d 'M' -f1) MiB/s | tee fio-$(hostname  | tr "[:upper:]" "[:lower:]").log 

rm $TEMP_DIR/*

echo FIOWriteIOPS: $(fio --name=write_iops --directory=$TEMP_DIR --size=2G --numjobs=2 --time_based --runtime=300s --ramp_time=2s --ioengine=libaio --direct=1 --verify=0 --bs=4K --iodepth=128 --rw=randwrite --group_reporting=1 | grep "write: IOPS=" | awk '{print $2}' | cut -d '=' -f2 | cut -d 'k' -f1) K | tee -a fio-$(hostname  | tr "[:upper:]" "[:lower:]").log

rm $TEMP_DIR/*

echo FIOReadTPT: $(fio --name=read_throughput --directory=$TEMP_DIR --numjobs=16 --size=10G --time_based --runtime=120s --ramp_time=2s --ioengine=libaio --direct=1 --verify=0 --bs=1M --iodepth=64 --rw=read --group_reporting=1  | grep "READ:" | awk '{print $2}' | cut -d '=' -f2 | cut -d 'M' -f1) MiB/s | tee -a fio-$(hostname | tr "[:upper:]" "[:lower:]").log

rm $TEMP_DIR/*

echo FIOReadIOPS: $(fio --name=read_iops --directory=$TEMP_DIR --size=2G --numjobs=2 --time_based --runtime=240s --ramp_time=2s --ioengine=libaio --direct=1 --verify=0 --bs=4K --iodepth=128 --rw=randread --group_reporting=1 | grep "read: IOPS=" | awk '{print $2}' | cut -d '=' -f2 | cut -d 'k' -f1) K | tee -a fio-$(hostname | tr "[:upper:]" "[:lower:]").log

rm $TEMP_DIR/*

