# This is a very careful series of tests for calico networkpolicy;

* The objective is to test
the namespace(tenant) isolation functionnality and it's stability.
south north funcntionnality control of tenant level and it's stability. 
if it's production ready of calico networkpolicy for shangqi. 

* Test steps include clear old env; setup env; 
waits env to be ready, and pick up ns by chance
to test connectivity between nses, and between ns and public 
network.
