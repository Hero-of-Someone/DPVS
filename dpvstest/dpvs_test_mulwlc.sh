#!/bin/bash
# test dpvs SLAAC function and RR 



rm /var/log/dpvs/dpvs.log

rm ./nohup.out

rm ./main.log

PID=$(ps -ef | grep /root/dpvs/bin/dpvs | grep -v grep | awk '{print $2}')

if [ -n "$PID" ]; then

        echo kill dpvs successful
                 
        kill -9 $PID
       
        echo after 5 second start dpvs        

        sleep 5  

        nohup /root/dpvs/bin/dpvs &        
     
        
else
        echo jar is not running dpvs

        echo start dpvs now

        nohup /root/dpvs/bin/dpvs &
fi

sleep 5
echo after 15 second check SLAAC IPv6 address
sleep 10



check_results=`/root/dpvs/bin/ipvsadm`
if [[ $check_results =~ "Connection refused" ]]
then
  echo "dpvs initialize failed"
fi
check_ipv6_results=`/root/dpvs/bin/dpip -6 route show | grep "inet6"`

echo -e  "
SLAAC_IPv6 address:\n$check_ipv6_results
         "

if [[ $check_ipv6_results =~ "inet6 fe80::" ]] 
then 
    /root/dpvs/bin/dpip addr add 2001:da8:2d01:20::55/64 dev dpdk0
    /root/dpvs/bin/ipvsadm -A -t [2001:da8:2d01:20::55]:80 -s wlc
    /root/dpvs/bin/ipvsadm -a -t [2001:da8:2d01:20::55]:80 -r 2001:0da8:2d01:0017:da51:fbbe:52f5:9234  -b -w 1 
    /root/dpvs/bin/ipvsadm -a -t [2001:da8:2d01:20::55]:80 -r 2001:0da8:2d01:0019:1f9b:fe00:777c:7490 -b -w 1 
    /root/dpvs/bin/ipvsadm -a -t [2001:da8:2d01:20::55]:80 -r 2001:0da8:2d01:0010:b551:c783:a080:37e7  -b -w 1 
    /root/dpvs/bin/ipvsadm --add-laddr -z 2001:da8:2d01:20::15 -t [2001:da8:2d01:20::55]:80 -F dpdk0
    /root/dpvs/bin/ipvsadm --add-laddr -z 2001:da8:2d01:20::16 -t [2001:da8:2d01:20::55]:80 -F dpdk0
    /root/dpvs/bin/ipvsadm --add-laddr -z 2001:da8:2d01:20::17 -t [2001:da8:2d01:20::55]:80 -F dpdk0
    echo -e "
            /root/dpvs/bin/dpip addr add 2001:da8:2d01:20::55/64 dev dpdk0
            /root/dpvs/bin/ipvsadm -A -t [2001:da8:2d01:20::55]:80 -s rr
            /root/dpvs/bin/ipvsadm -a -t [2001:da8:2d01:20::55]:80 -r 2001:0da8:2d01:0017:da51:fbbe:52f5:9234 -b -w 1 
            /root/dpvs/bin/ipvsadm -a -t [2001:da8:2d01:20::55]:80 -r 2001:0da8:2d01:0019:1f9b:fe00:777c:7490 -b -w 1 
            /root/dpvs/bin/ipvsadm -a -t [2001:da8:2d01:20::55]:80 -r 2001:0da8:2d01:0010:b551:c783:a080:37e7  -b -w 1 
            /root/dpvs/bin/ipvsadm --add-laddr -z 2001:da8:2d01:20::15 -t [2001:da8:2d01:20::55]:80 -F dpdk0
            /root/dpvs/bin/ipvsadm --add-laddr -z 2001:da8:2d01:20::16 -t [2001:da8:2d01:20::55]:80 -F dpdk0
            /root/dpvs/bin/ipvsadm --add-laddr -z 2001:da8:2d01:20::17 -t [2001:da8:2d01:20::55]:80 -F dpdk0
            "
else 
    echo "SLAAC IPv6 address failed"    
fi
sleep 5
dpvs_results=`/root/dpvs/bin/ipvsadm`
if [[ $dpvs_results =~ "RemoteAddress:Port" ]]
then
  echo "
show ipvsadm:
       "
  echo "$dpvs_results"
else
  echo "ipvsadm failed"
fi

check_ipv6_results_all=`/root/dpvs/bin/dpip -6 route show | grep "inet6"`

echo -e  "
all IPv6 address:\n$check_ipv6_results_all
         "
