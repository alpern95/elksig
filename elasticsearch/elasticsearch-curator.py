#!/usr/bin/env python

import json, subprocess, socket

CONFIGURATION_FILE = "/etc/elasticsearch/curator.json"

def parse_configuration_file():
	with open(CONFIGURATION_FILE) as f:
		return json.load(f)

def exec_curator(config):
	host = socket.gethostname()
	for retention in config['retentions']:
		prefix = retention['prefix']
		days = retention['days']
		print "Calling '/usr/local/bin/curator --hosts %s delete --prefix %s --older-than %d'" % (host, prefix, days)
		subprocess.call(["/usr/local/bin/curator", "--host", host, "delete", "--prefix", prefix, "--older-than", str(days)])

def main():
	config = parse_configuration_file()
	exec_curator(config)

main()