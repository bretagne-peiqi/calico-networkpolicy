# This is a very strict series of tests for calico networkpolicy;

### calico networkpolicy configuration does not always behave as expect;

### we include some conclusion and give some config file which works fine and present functional tests.

* Objective
test the namespace(tenant) isolation functionnality and it's stability.
south north funcntionnality control of tenant level and it's stability. 
if it's production ready of calico networkpolicy. 

* Test steps 
clear old env; 
setup env; 
waits env to be ready, and pick up ns by chance
to test connectivity between nses,
between ns and public network.
