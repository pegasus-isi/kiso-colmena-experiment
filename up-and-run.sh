#!/bin/bash

kiso --debug up --force
rm secrets/hosts
source secrets/fabric_rc
bin/fabric-hosts.py
kiso --debug run
