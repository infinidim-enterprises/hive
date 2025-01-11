#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p "python3.withPackages (p: [])"

import ipaddress
import json
import sys

def transform_ptr(ptr):
    parts = ptr.split('.')
    if '/' in parts[0]:
        parts = parts[1:]
    transformed_ptr = '.'.join(parts)

    return transformed_ptr

def get_addr_space(ip_network):
    if ip_network.is_private:
        return "Private Use"
    elif ip_network.is_global:
        return "Global"
    elif ip_network.is_loopback:
        return "Loopback"
    elif ip_network.is_link_local:
        return "Link Local"
    elif ip_network.is_multicast:
        return "Multicast"
    else:
        return "Unknown"

def generate_network_info(cidr):
    network = ipaddress.ip_network(cidr, strict=False)
    all_addresses = [str(ip) for ip in network.hosts()]
    info = {
        "network": str(network.network_address),
        "netmask": str(network.netmask),
        "prefix": str(network.prefixlen),
        "broadcast": str(network.broadcast_address),
        "addrspace": get_addr_space(network),
        "minaddr": str(network.network_address + 1),
        "minaddrptr": str((network.network_address + 1).reverse_pointer),
        "maxaddr": str(network.broadcast_address - 1),
        "addresses": str(network.num_addresses - 2),
        "hosts": all_addresses,
        "pool": f"{str(network.network_address + 2)} - {str(network.broadcast_address - 2)}",
        "ptr": str(transform_ptr(network.reverse_pointer))
    }

    return info

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <CIDR>")
        sys.exit(1)

    cidr = sys.argv[1]
    try:
        network_info = generate_network_info(cidr)
        print(json.dumps(network_info, indent=2))
    except ValueError as e:
        print(f"Invalid CIDR notation: {e}")
