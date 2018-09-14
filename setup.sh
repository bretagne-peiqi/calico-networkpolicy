#!/usr/bin/env bash

###this script will create 200 isolated namespaces;
###all namespaces will be labeld by ns: test$i and a different network policy will be applied.
###in each ns; there will create several service; by default they cann't visit public network.
set +o errexit

###args $1 is the cluster number going to define ...
function Setup() {
for i in `seq 1 $1`; do 
kubectl create -f -<<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: ns-test$i
  labels:
    ns: test$i
EOF
done

for i in `seq 1 $1`; do
kubectl create -f -<<EOF
#make pods visitable in the same ns
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: default-deny
  namespace: ns-test$i
spec:
  podSelector:
    matchLabels:
      user: test$i
  ingress:
  - from:
    - ipBlock:
       cidr: 10.0.0.0/8
    - namespaceSelector:
       matchLabels:
         ns: test$i
  egress:
  - to:
    - namespaceSelector:
       matchLabels:
         ns: test$i
    - ipBlock:
        cidr: 10.0.0.0/8
EOF
done


for i in `seq 1 $1`; do 
kubectl create -f -<<EOF
# Example replication controller for an iperf service.
apiVersion: v1
kind: ReplicationController
metadata:
  name: iperf-server-controller
  namespace: ns-test$i
spec:
  replicas: 3
  selector:
    user: test$i
  template:
    metadata:
      labels:
        user: test$i
    spec:
      containers:
      - name: iperf-server
        image: docker-registry.telecom.com/chenqiang/nginx-hello:v2.0
EOF
done


for i in `seq 9 19`; do 
kubectl create -f -<<EOF
# Example replication controller for an iperf service.
apiVersion: v1
kind: ReplicationController
metadata:
  name: iperf-server-controller2
  namespace: ns-test$i
spec:
  replicas: 3
  selector:
    name: test2$i
  template:
    metadata:
      labels:
        user: test$i
        name: test2$i
    spec:
      containers:
      - name: iperf-server
        image: docker-registry.telecom.com/chenqiang/nginx-hello:v2.0
EOF
done

for i in `seq 9 19`; do 
kubectl create -f -<<EOF
# Example replication controller for an iperf service.
apiVersion: v1
kind: ReplicationController
metadata:
  name: iperf-server-controller3
  namespace: ns-test$i
spec:
  replicas: 3
  selector:
    name: test3$i
  template:
    metadata:
      labels:
        user: test$i
        name: test3$i
    spec:
      containers:
      - name: iperf-server
        image: docker-registry.telecom.com/chenqiang/nginx-hello:v2.0
EOF
done


for i in `seq 9 19`; do 
kubectl create -f -<<EOF
# Example replication controller for an iperf service.
apiVersion: v1
kind: ReplicationController
metadata:
  name: iperf-server-controller4
  namespace: ns-test$i
spec:
  replicas: 3
  selector:
    name: test4$i
  template:
    metadata:
      labels:
        name: test4$i
        user: test$i
    spec:
      containers:
      - name: iperf-server
        image: docker-registry.telecom.com/chenqiang/nginx-hello:v2.0
EOF
done

for i in `seq 9 19`; do
kubectl create -f -<<EOF
apiVersion: v1
kind: Service
metadata:
  name: networking-service$i
  namespace: ns-test$i
  labels:
    name: networking-service$i
spec:
  ports:
  - port: 5089
    targetPort: 80
    protocol: TCP
  selector:
    user: test2$i
EOF
done

for i in `seq 9 19`; do
kubectl create -f -<<EOF
apiVersion: v1
kind: Service
metadata:
  name: networking-service4
  namespace: ns-test$i
  labels:
    name: networking-service4
spec:
  ports:
  - port: 5085
    targetPort: 80
    protocol: TCP
  selector:
    user: test4$i
EOF
done

for i in `seq 9 19`; do
kubectl create -f -<<EOF
apiVersion: v1
kind: Service
metadata:
  name: networking-service3
  namespace: ns-test$i
  labels:
    name: networking-service3
spec:
  ports:
  - port: 5087
    targetPort: 80
    protocol: TCP
  selector:
    user: test3$i
EOF
done

for i in `seq 1 $1`; do
kubectl create -f -<<EOF
apiVersion: v1
kind: Service
metadata:
  name: networking-service
  namespace: ns-test$i
  labels:
    name: networking-service
spec:
  ports:
  - port: 5081
    targetPort: 80
    protocol: TCP
  selector:
    name: test$i
EOF
done

}
