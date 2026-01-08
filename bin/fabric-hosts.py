#!/usr/bin/env python3

from fabrictestbed_extensions.fablib.fablib import FablibManager as fablib_manager

fablib = fablib_manager()
slice = fablib.get_slice('fabric')

lines = []

for site in ("WASH", "UTAH", "HAWI"):
    n = slice.get_network(name=f"FABNetv4-IPv4-{site}")
    for i in n.get_interfaces():
        ip = i.get_ip_addr()
        name = i.get_node().get_name()
        lines.append(f"{ip} {name}")

# Append to /etc/hosts
with open("secrets/hosts", "a") as f:
    f.write("\n# FABRIC nodes\n")
    for line in lines:
        f.write(line + "\n")
