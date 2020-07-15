#!/bin/sh
#
# chkconfig: - 85 15 ## 运行级别、启动优先级、关闭优先级
# description: HA-Proxy is a TCP/HTTP reverse proxy which is particularly suited \
#              for high availability environments.
# processname: haproxy
# config: /usr/local/haproxy/etc/haproxy.cfg
# pidfile: /usr/local/haproxy/var/run/haproxy.pid

# Source function library.
if [ -f /etc/init.d/functions ]; then
  . /etc/init.d/functions
elif [ -f /etc/rc.d/init.d/functions ]; then
  . /etc/rc.d/init.d/functions
else
  exit 0
fi

# Source networking configuration.
. /etc/sysconfig/network

# Check that networking is up.
[ ${NETWORKING} = "no" ] && exit 0

# 服务脚本名称
BASENAME=`basename $0`
if [ -L $0 ]; then
  BASENAME=`find $0 -name $BASENAME -printf %l`
  BASENAME=`basename $BASENAME`
fi

BIN=/usr/local/haproxy/sbin/$BASENAME

CFG=/usr/local/haproxy/etc/$BASENAME.cfg
[ -f $CFG ] || exit 1

PIDFILE=/usr/local/haproxy/var/run/$BASENAME.pid
LOCKFILE=/var/lock/subsys/$BASENAME

RETVAL=0

start() {
  quiet_check
  if [ $? -ne 0 ]; then
    echo "Errors found in configuration file, check it with '$BASENAME check'."
    return 1
  fi

  echo -n "Starting $BASENAME: "
  daemon $BIN -D -f $CFG -p $PIDFILE
  RETVAL=$?
  echo
  [ $RETVAL -eq 0 ] && touch $LOCKFILE
  return $RETVAL
}

stop() {
  echo -n "Shutting down $BASENAME: "
  killproc $BASENAME -USR1
  RETVAL=$?
  echo
  [ $RETVAL -eq 0 ] && rm -f $LOCKFILE
  [ $RETVAL -eq 0 ] && rm -f $PIDFILE
  return $RETVAL
}

restart() {
  quiet_check
  if [ $? -ne 0 ]; then
    echo "Errors found in configuration file, check it with '$BASENAME check'."
    return 1
  fi
  stop
  start
}

reload() {
  if ! [ -s $PIDFILE ]; then
    return 0
  fi

  quiet_check
  if [ $? -ne 0 ]; then
    echo "Errors found in configuration file, check it with '$BASENAME check'."
    return 1
  fi
  $BIN -D -f $CFG -p $PIDFILE -sf $(cat $PIDFILE)
}

check() {
  $BIN -c -q -V -f $CFG
}

quiet_check() {
  $BIN -c -q -f $CFG
}

rhstatus() {
  status $BASENAME
}

condrestart() {
  [ -e $LOCKFILE ] && restart || :
}

# 可用方法
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  reload)
    reload
    ;;
  condrestart)
    condrestart
    ;;
  status)
    rhstatus
    ;;
  check)
    check
    ;;
  *)
    echo "Usage: $BASENAME {start|stop|restart|reload|condrestart|status|check}"
    exit 1
esac

exit $?
