#!/bin/bash

set -ex


action=$1


source /etc/openvswitch/default.conf
source /etc/sysconfig/openvswitch
if [ -e "/run/openvswitch.useropts" ]; then
  source /run/openvswitch.useropts
fi


function prepare() {
  chown :"${OVS_USER_ID##*:}" /dev/hugepages
  chmod 0775 /dev/hugepages
}


function start() {
  /usr/share/openvswitch/scripts/ovs-ctl --no-ovsdb-server \
    --no-monitor --system-id=random ${OVS_USER_OPT} \
    start $OPTIONS
}


function wait() {
  while [ -e /var/run/openvswitch/ovs-vswitchd.pid ]; do
    sleep 2
  done
}


function stop() {
  /usr/share/openvswitch/scripts/ovs-ctl --no-ovsdb-server \
    stop
}


function reload() {
  /usr/share/openvswitch/scripts/ovs-ctl --no-ovsdb-server \
    --no-monitor --system-id=random ${OVS_USER_OPT} \
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