#!/usr/bin/env python3

from fabrictestbed_extensions.fablib.fablib import FablibManager as fablib_manager

fablib = fablib_manager()
slice = fablib.get_slice('colmena')

# Static mapping: node hostname -> alias
HOST_ALIAS = {
    "colmena-sLOSA-m1-n1": "agent-1",
    "colmena-sLOSA-m1-n2": "agent-2",
    "colmena-sLOSA-m1-n3": "agent-3",
    "colmena-sLOSA-m4-n1": "andes",

    "colmena-sUTAH-m3-n1": "agent-7",
    "colmena-sUTAH-m3-n2": "agent-8",
    "colmena-sUTAH-m3-n3": "agent-9",

    "colmena-sHAWI-m2-n1": "agent-4",
    "colmena-sHAWI-m2-n2": "agent-5",
    "colmena-sHAWI-m2-n3": "agent-6",
}

lines = []

for site in ("LOSA", "UTAH", "HAWI"):
    net = slice.get_network(name=f"FABNetv4-IPv4-{site}")
    for iface in net.get_interfaces():
        ip = iface.get_ip_addr()
        hostname = iface.get_node().get_name()

        alias = HOST_ALIAS.get(hostname)
        if alias is None:
            # Skip or warn if an unexpected node appears
            print(f"Warning: no alias for {hostname}")
            continue

        lines.append(f"{ip} {hostname} {alias}")

# Append to hosts file
with open("secrets/hosts", "a") as f:
    f.write("\n# FABRIC nodes\n")
    for line in lines:
        f.write(line + "\n")
