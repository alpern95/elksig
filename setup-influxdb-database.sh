#!/bin/bash

curl -G http://localhost:8086/query --data-urlencode "q=CREATE USER admin-influx WITH PASSWORD 'changeme' WITH ALL PRIVILEGES"

curl -G http://localhost:8086/query --data-urlencode "q=CREATE DATABASE sensu"

curl -G http://localhost:8086/query --data-urlencode "q=CREATE USER sensu WITH PASSWORD 'changeme'"

