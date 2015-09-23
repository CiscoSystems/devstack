#!/bin/bash

# Runs phase 1 install and demo scripts in the right order.

# osn is the name of Openstack network service, i.e.,
# it should be either 'neutron' or 'quantum', for
# release >=Havana and release <=Grizzly, respectively.
osn=${1:-neutron}


source ~/devstack/openrc admin demo
echo "***************** Setting up Keystone for CSR1kv *****************"
./setup_keystone_for_csr1kv_l3.sh $osn

echo 'Done!...'
