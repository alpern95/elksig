#!/bin/bash
cd influxdbdata
docker build -t elksig/influxdbdata .
cd ..
cd elasticsearchdata/
docker build -t elksig/elasticsearchdata .
cd ..
cd slapd/
docker build -t elksig/slapd .
cd ..

