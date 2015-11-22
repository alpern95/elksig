#!/bin/bash

set -m
CONFIG_FILE="/config/config.toml"
exec /usr/bin/influxd -config=${CONFIG_FILE}
