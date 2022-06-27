#!/bin/bash

disk=$1
testtype=$2

export wdir=$(pwd)

sudo yum install pssh -y

echo "beginning date: $(date)"
echo $(hostname | tr "[:upper:]" "[:lower:]") > hosts.txt

#if command -v pbsnodes --version &> /dev/null
#then
#	pbsnodes -avS | grep free | awk -F ' ' '{print tolower($1)}' >> hosts.txt
#fi

pssh -p 200 -t 600 -i -h hosts.txt "cd $wdir && ./fio_test.sh $disk $testtype" >> fio_pssh.log 2>&1

if [ $testtype == "complete" ]
then 
	IFS=$'\n' read -d '' -r -a names < ./hosts.txt
	echo -e "SYSTEM\tWrTPT(MiB/s)\tWrIOPS(k)\tRdTPT(MiB/s)\tRdIOPS(k)" > fio-$testtype-$disk-test-results.log
	echo "*****************************************************************" >> fio-$testtype-$disk-test-results.log
	for i in ${names[@]}; do
		readarray -t arr <fio-${i}-$testtype-$disk.log
		echo -e "${i}\t$(echo ${arr[0]} | awk '{print $2}')\t$(echo ${arr[1]} | awk '{print $2}')\t\t$(echo ${arr[2]} | awk '{print $2}')\t\t$(echo ${arr[3]} | awk '{print $2}')" >> fio-$testtype-$disk-test-results.log
	done

	for i in ${names[@]}; do
		readarray -t arr <fio-${i}-$testtype-$disk.log
		echo -e "system: ${i} WrTPT: $(echo ${arr[0]} | awk '{print $2}')" >> fio-$disk-wr-tpt-results.log
		echo -e "system: ${i} WrIOPS: $(echo ${arr[1]} | awk '{print $2}')" >> fio-$disk-wr-iops-results.log
		echo -e "system: ${i} RdTPT: $(echo ${arr[2]} | awk '{print $2}')" >> fio-$disk-rd-tpt-results.log
		echo -e "system: ${i} RdIOPS: $(echo ${arr[3]} | awk '{print $2}')" >> fio-$disk-rd-iops-results.log
	done
elif [ $testtype == "quick" ]
then
	IFS=$'\n' read -d '' -r -a names < ./hosts.txt
	echo -e "SYSTEM\tWrTPT(MiB/s)" > fio-$testtype-$disk-test-results.log
        echo "*****************************************************************" >> fio-$testtype-$disk-test-results.log
	for i in ${names[@]}; do
                readarray -t arr <fio-${i}-$testtype-$disk.log
                echo -e "${i}\t$(echo ${arr[0]} | awk '{print $2}')" >> fio-$testtype-$disk-test-results.log
        done

	for i in ${names[@]}; do
                readarray -t arr <fio-${i}-$testtype-$disk.log
		echo -e "system: ${i} WrTPT: $(echo ${arr[0]} | awk '{print $2}')" >> fio-$disk-wr-tpt-results.log
	done

else
	echo "Not a proper test type!"
fi

echo "end date: $(date)"

