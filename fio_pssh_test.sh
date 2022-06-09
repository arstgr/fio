#!/bin/bash

export wdir=$(pwd)

sudo yum install pssh -y

echo "beginning date: $(date)"
echo $(hostname | tr "[:upper:]" "[:lower:]") > hosts.txt

if command -v pbsnodes --version &> /dev/null
then
	pbsnodes -avS | grep free | awk -F ' ' '{print tolower($1)}' >> hosts.txt
fi

pssh -p 301 -t 0 -i -h hosts.txt "cd $wdir && ./fio_test.sh" >> fio_pssh.log 2>&1


sleep 10

IFS=$'\n' read -d '' -r -a names < ./hosts.txt
echo -e "SYSTEM\tWrTPT(MiB/s)\tWrIOPS(k)\tRdTPT(MiB/s)\tRdIOPS(k)" > fio-test-results.log
echo "*****************************************************************" >> fio-test-results.log
for i in ${names[@]}; do
	readarray -t arr <fio-${i}.log
	echo -e "${i}\t$(echo ${arr[0]} | awk '{print $2}')\t$(echo ${arr[1]} | awk '{print $2}')\t\t$(echo ${arr[2]} | awk '{print $2}')\t\t$(echo ${arr[3]} | awk '{print $2}')" >> fio-test-results.log
done


for i in ${names[@]}; do
	readarray -t arr <fio-${i}.log
	echo -e "system: ${i} WrTPT: $(echo ${arr[0]} | awk '{print $2}')" >> fio-wr-tpt-results.log
	echo -e "system: ${i} WrIOPS: $(echo ${arr[1]} | awk '{print $2}')" >> fio-wr-iops-results.log
	echo -e "system: ${i} RdTPT: $(echo ${arr[2]} | awk '{print $2}')" >> fio-rd-tpt-results.log
	echo -e "system: ${i} RdIOPS: $(echo ${arr[3]} | awk '{print $2}')" >> fio-rd-iops-results.log
done
echo "end date: $(date)"
