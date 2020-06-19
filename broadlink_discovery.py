#!/usr/bin/env python

import argparse
import json

import broadlink
from broadlink.exceptions import StorageError

parser = argparse.ArgumentParser(fromfile_prefix_chars='@')
parser.add_argument("--timeout", type=int, default=5, help="timeout to wait for receiving discovery responses")
parser.add_argument("--ip", default=None, help="ip address to use in the discovery")
parser.add_argument("--dst-ip", default="255.255.255.255", help="destination ip address to use in the discovery")
args = parser.parse_args()

#print("Discovering...")

devices = broadlink.discover(timeout=args.timeout, local_ip_address=args.ip, discover_ip_address=args.dst_ip)

data = []
for device in devices:
    if device.auth():
        data.append({ "type": device.type,
            "devtype": "{}".format(hex(device.devtype)),
            "host": device.host[0],
            "mac": ":".join(format(x, '02x') for x in device.mac),
            "error": None
        });

    else:
    	data.append({"error": "Error authenticating"})
print(json.dumps(data))

