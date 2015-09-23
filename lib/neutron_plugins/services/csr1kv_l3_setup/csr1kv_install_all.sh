#!/bin/bash

# Runs all install and demo scripts in the right order.

echo "***************** Running phase 1 setup *****************"
./csr1kv_install_phase1.sh

echo "***************** Running phase 2 setup *****************"
./csr1kv_install_phase2.sh

