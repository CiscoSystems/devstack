#!/bin/bash

# Runs phase 2 install and demo scripts in the right order.

# osn is the name of Openstack network service, i.e.,
# it should be either 'neutron' or 'quantum', for
# release >=Havana and release <=Grizzly, respectively.
osn=${1:-neutron}
#plugin=${2:-ovs}
plugin=${2:-n1kv}
localrc=$3
mysql_user=$4
mysql_password=$5
mgmt_ip=$6

# Adopted from Devstack scripts:
# Normalize config values to True or False
# Accepts as False: 0 no No NO false False FALSE
# Accepts as True: 1 yes Yes YES true True TRUE
# VAR=$(trueorfalse default-value test-value)
function trueorfalse {
    local xtrace=$(set +o | grep xtrace)
    set +o xtrace
    local default=$1
    local testval=$2

    [[ -z "$testval" ]] && { echo "$default"; return; }
    [[ "0 no No NO false False FALSE" =~ "$testval" ]] && { echo "False"; return; }
    [[ "1 yes Yes YES true True TRUE" =~ "$testval" ]] && { echo "True"; return; }
    echo "$default"
    $xtrace
}


if [[ ! -z $localrc && -f $localrc ]]; then
    eval $(grep ^Q_CISCO_CREATE_TEST_NETWORKS= $localrc)
    eval $(grep ^Q_CISCO_CONFIGURE_NOVA_AND_GLANCE= $localrc)
fi
CREATE_TEST_NETWORKS=$(trueorfalse "False" $Q_CISCO_CREATE_TEST_NETWORKS)
CONFIGURE_NOVA_AND_GLANCE=$(trueorfalse "True" $CONFIGURE_NOVA_AND_GLANCE)
Q_CISCO_IS_EXTRA_CONFIG_AGENT=$(trueorfalse "True" $Q_CISCO_IS_EXTRA_CONFIG_AGENT)

source ~/devstack/openrc $osn L3AdminTenant

if [[ "$Q_CISCO_IS_EXTRA_CONFIG_AGENT" == "False" ]]; then
    if  [[ "$CONFIGURE_NOVA_AND_GLANCE" == "True" ]]; then
        echo "***************** Setting up Nova & Glance for CSR1kv *****************"
        ./setup_nova_and_glance_for_csr1kv_l3.sh $osn $localrc $mysql_user $mysql_password
    fi

    echo "***************** Setting up Neutron for CSR1kv *****************"
    ./setup_neutron_for_csr1kv_l3.sh $osn $plugin $localrc
fi

echo "***************** Setting up CfgAgent connectivity *****************"
./setup_l3cfgagent_networking.sh $osn $plugin $localrc $mgmt_ip

if [[ "$Q_CISCO_IS_EXTRA_CONFIG_AGENT" == "False" ]]; then
    if [[ "$CREATE_TEST_NETWORKS" == "True" ]]; then
        source ~/devstack/openrc admin demo
        echo "***************** Setting up test networks *****************"
       ./setup_test_networks.sh $osn $plugin
       ./setup_interface_on_extnet1_for_demo.sh $osn $plugin
    fi
fi
echo 'Done!...'
