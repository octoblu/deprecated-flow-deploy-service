#!/bin/bash

echo "Setting etcd defaults for development mode"
etcdctl set /meshblu/host 172.17.8.1
etcdctl set /meshblu/port 3000
etcdctl set /node/env development
etcdctl set /octoblu/uri http://172.17.8.1:8080
etcdctl set /octoblu/flow-runner/env/DEBUG flow-runner*
etcdctl set /flow-deploy-service/base-uri http://172.17.8.1:8899
