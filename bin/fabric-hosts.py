#!/usr/bin/env python3

from fabrictestbed_extensions.fablib.fablib import FablibManager as fablib_manager

fablib = fablib_manager()
slice = fablib.get_slice('colmena')

# Sites in slice (order determines agent numbering)
SITES = ("LOSA", "HAWI", "UCSD", "STAR", "BRIST", "FIU")

lines = []
agent_counter = 1  # Sequential agent IDs from 1 → 18

# Special alias exceptions
SPECIAL_ALIAS = {
    "colmena-sLOSA-m7-n1": "andes"
}

for site in SITES:
    net = slice.get_network(name=f"FABNetv4-IPv4-{site}")
    # Build dict: hostname -> iface
    nodes_dict = {iface.get_node().get_name(): iface for iface in net.get_interfaces()}
    # Sort hostnames for deterministic order
    for hostname in sorted(nodes_dict.keys()):
        iface = nodes_dict[hostname]
        ip = iface.get_ip_addr()

        if hostname in SPECIAL_ALIAS:
            alias = SPECIAL_ALIAS[hostname]
        else:
            alias = f"agent-{agent_counter}"
            agent_counter += 1

        lines.append(f"{ip} {hostname} {alias}")


# Append to hosts file
with open("secrets/hosts", "a") as f:
    f.write("\n# FABRIC nodes\n")
    for line in lines:
        f.write(line + "\n")

print(f"Processed {agent_counter - 1} nodes plus {len(SPECIAL_ALIAS)} special aliases. Hosts updated.")
