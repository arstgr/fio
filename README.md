# FIO Disk Performance Benchmark

Scripts to run the FIO disk performance benchmark on Azure. The tests rely on pssh for parallel launch of the test on all the cluster nodes, and pbs for obtaining the node list. SUpport for additional schedulers will be added in future. 

To run 
```
./fio_pssh_test.sh
```
