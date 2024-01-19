#!/bin/bash

set -ex


action=$1


function start() {
  if podman ps --all  | grep -w -q ovs-vswitchd; then
  	podman start ovs-vswitchd
    return
  fi

  podman run --detach \
    --privileged \
    --name ovs-vswitchd \
    --volume /dev:/dev \
    --network=host \
    --volume /etc/openvswitch:/etc/openvswitch \
    --volume /etc/sysconfig:/etc/sysconfig \
    --volume /opt/script:/opt/script \
    --volume /run/openvswitch:/run/openvswitch \
    --volume /var/log/openvswitch:/var/log/openvswitch \
    hub.easystack.cn/escl-switch/es8 \
    /opt/script/ovs-vswitchd.sh start
}


function stop() {
  if ! podman ps | grep -w -q ovs-vswitchd; then
    return
  fi
  podman exec ovs-vswitchd /opt/script/ovs-vswitchd.sh stop
}


function reload() {
  podman exec ovs-vswitchd /opt/script/ovs-vswitchd.sh reload
}


function status() {
  if ! podman ps | grep -w ovs-vswitchd; then
    echo "ovs-vswitchd not runing"
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
    podman rm ovs-vswitchd
    ;;
  "*")
    echo "not support"
    ;;
esac