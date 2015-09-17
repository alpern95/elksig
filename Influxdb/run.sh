#!/bin/bash

set -m
CONFIG_FILE="/config/config.toml"
exec /opt/influxdb/influxd -config=${CONFIG_FILE}

