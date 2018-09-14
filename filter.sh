#!/usr/bin/env bash

set +o errexit

#### we should specify 2 args in this scripts; $1 is used to define pick up ns numbers to check; 
#### $2 is used to define cluster namespace number ...

###global var; if you want define local var: add local at front
del=0

if [ $# != 2 ]; then
 echo "please specify going-to-be-tested ns number and cluster ns number"
fi

###delete all ns ...
for x in `seq 1 $2`; do
kubectl delete -f -<<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: ns-test$x
  labels:
    name: test$x
EOF

if [ $? == 0 ]; then
	del=1
fi
done

### if $? not equal to 0; means error;
if [ $del == 1 ]; then
    echo "waiting to clear all ..."
	while true;
	do
	flag=0
	#min=`expr $2 - 20` respect the rule; check all ns...
	echo "checking pods in ns... sleeping to delete ..."
	for i in `seq 1 $2`; do
		cnt=`kubectl get po -n ns-test$i|wc -l` 
		if [ $cnt -gt 1 ]; then
			flag=1
		else
			 continue
	    fi
	done
	if [ $flag == 0 ]; then
		break;
	fi
	done
fi
sleep 5

echo "we are going to setup new env..."
### import setup function to setup the test env...
basepath=$(cd `dirname $0`; pwd)
.  $basepath/setup.sh

Setup $2

###wait it all to turn into Running state;
while true; do
flag=0
echo "sleeping to be env ready..."
for i in `seq 1 $2`; do
	cnt=`kubectl get po -n ns-test$i -o wide|grep -v Running|wc -l`
	if [ $cnt -gt 2 ]; then
		flag=1
	else
		continue
	fi
done
	if [ $flag == 0 ]; then
		break;
	fi

done

### as we created about 200 ns; it's hard to check all of them; 
### so the idea is to select some of them and check.
chiff=`shuf -i 1-$2 -n $1`
for i in $chiff; do 
	echo "checking ns $i ..."
	pods=`kubectl get po -n ns-test$i -o wide|grep Running|awk {'print $1'}`
	for j in $pods; do
		for n in `seq 1 $2`; do
			ipaddr=`kubectl get pods -n ns-test$n -o wide|grep Running|awk {'print $6'}`
			for addr in $ipaddr; do 
				### expected result: all $j are pods in ns $i; 
        	                ### they should not pingcheable to any addr except pods in same ns;
				kubectl exec -it $j -n ns-test$i -- ping -c 1 -W 1 $addr>/dev/null 2>&1
				if [ $? == 0 ]; then
				   echo "ping rechable: from pods $j ns ns-test$i to caddr $addr in ns ns-test$n"	
				fi	
			done
		done
	done
done

### this part is used to test south-north traffic network policy...
for n in `seq 1 $2`; do
	pods=`kubectl get pods -n ns-test$n -o wide|grep Running |awk {'print $1'}`
	for i in $pods; do
		kubectl exec -it $i -n ns-test$n -- ping -c 1 -W 1 114.114.114.114>/dev/null 2>&1
		if [ $? == 0 ]; then
			echo "ping reachable 114.114.114.114: from pods$i in ns ns-test$n"
		fi
	done
done

exit 0
