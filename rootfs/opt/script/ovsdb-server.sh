#!/bin/bash

set -ex


action=$1


source /etc/openvswitch/default.conf
source /etc/sysconfig/openvswitch
if [ -e "/run/openvswitch.useropts" ]; then
  source /run/openvswitch.useropts
fi


function prepare() {
  rm -f /run/openvswitch.useropts
  chown ${OVS_USER_ID} /var/run/openvswitch /var/log/openvswitch
  echo "OVS_USER_ID=${OVS_USER_ID}" > /run/openvswitch.useropts
  if [ "$${OVS_USER_ID/:*/}" != "root" ]; then
    echo "OVS_USER_OPT=--ovs-user=${OVS_USER_ID}" >> /run/openvswitch.useropts; 
  fi
}


function start() {
  /usr/share/openvswitch/scripts/ovs-ctl --no-ovs-vswitchd \
    --no-monitor --system-id=random ${OVS_USER_OPT} \
    start $OPTIONS
}


function wait() {
  while [ -e /var/run/openvswitch/ovsdb-server.pid ]; do
    sleep 2
  done
}


function stop() {
  /usr/share/openvswitch/scripts/ovs-ctl --no-ovs-vswitchd \
    stop
}


function reload() {
  /usr/share/openvswitch/scripts/ovs-ctl --no-ovs-vswitchd \
    --no-monitor ${OVS_USER_OPT} \
    restart $OPTIONS
}


case "$action" in
  "s"|"start")
    prepare
    start
    set +x
    wait
    set -x
    ;;
  "p"|"stop")
    stop
    ;;
  "*")
    echo "dont support action: $action"
    ;;
esac