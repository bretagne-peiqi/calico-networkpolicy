# This is a very careful series of tests for calico networkpolicy;

the objective is to test if 
the namespace(tenant) isolation functionnality and stability.
south north funcntionnality control of tenant level. 
production ready of calico networkpolicy 

steps include clear old env; setup env; 
waits it to be ready, and pick up ns by chance
to test connectivity between nses, and between ns and public 
network.
