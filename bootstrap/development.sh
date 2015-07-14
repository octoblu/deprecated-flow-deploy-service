#!/bin/bash


etcdctl set /meshblu/host localhost
etcdctl set /meshblu/port 3000
etcdctl set /node/env development
etcdctl set /octoblu/uri http://localhost:8080
