#!/bin/bash

set -ex


action=$1


function start() {
  if podman ps --all  | grep -w -q ovsdb-server; then
  	podman start ovsdb-server
    return
  fi

  podman run --detach \
    --privileged \
    --name ovsdb-server \
    --network=host \
    --volume /etc/openvswitch:/etc/openvswitch \
    --volume /etc/sysconfig:/etc/sysconfig \
    --volume /opt/script:/opt/script \
    --volume /run/openvswitch:/run/openvswitch \
    hub.easystack.cn/escl-switch/es8 \
    /opt/script/ovsdb-server.sh start
}


function stop() {
  if ! podman ps | grep -w -q ovsdb-server; then
    return
  fi
  podman exec ovsdb-server /opt/script/ovsdb-server.sh stop
}


function reload() {
  podman exec ovsdb-server /opt/script/ovsdb-server.sh reload
}


function status() {
  if ! podman ps | grep -w ovsdb-server; then
    echo "ovsdb-server not runing"
    return
  fi
}


case "$action" in
  "s"|"start")
    start
    ;;
  "p"|"stop")
    stop
    ;;
  "r"|"reload")
    reload
    ;;
  "l"|"status")
    status
    ;;
  "c"|"clear")
    stop
    podman rm ovsdb-server
    ;;
  "*")
    echo "not support"
    ;;
esac