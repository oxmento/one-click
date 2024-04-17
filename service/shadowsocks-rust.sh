#!/usr/bin/env bash
# chkconfig: 2345 90 10
# description: A secure socks5 proxy, designed to protect your Internet traffic.

### BEGIN INIT INFO
# Provides:          Shadowsocks-rust
# Required-Start:    $network $syslog
# Required-Stop:     $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Fast tunnel proxy that helps you bypass firewalls
# Description:       Start or stop the Shadowsocks-rust server
### END INIT INFO


if [ -f /usr/local/bin/ssservice ]; then
    DAEMON=/usr/local/bin/ssservice
elif [ -f /usr/bin/ssservice ]; then
    DAEMON=/usr/bin/ssservice
fi
NAME=Shadowsocks-rust
CONF=/etc/shadowsocks/config.json
LOG=/var/log/shadowsocks-rust.log
PID_DIR=/var/run
PID_FILE=$PID_DIR/shadowsocks-rust.pid
RET_VAL=0

[ -x $DAEMON ] || exit 0

if [ ! -d "$(dirname ${LOG})" ]; then
    mkdir -p $(dirname ${LOG})
fi

check_pid(){
	get_pid=`ps -ef |grep -v grep | grep $DAEMON |awk '{print $2}'`
}

check_pid
if [ -z $get_pid ]; then
    if [ -e $PID_FILE ]; then
        rm -f $PID_FILE
    fi
fi

if [ ! -d $PID_DIR ]; then
    mkdir -p $PID_DIR
    if [ $? -ne 0 ]; then
        echo "Creating PID directory $PID_DIR failed"
        exit 1
    fi
fi

if [ ! -f $CONF ]; then
    echo "$NAME config file $CONF not found"
     exit 1
fi

check_running() {
    if [ -e $PID_FILE ]; then
        if [ -r $PID_FILE ]; then
            read PID < $PID_FILE
            if [ -d "/proc/$PID" ]; then
                return 0
            else
                rm -f $PID_FILE
                return 1
            fi
        fi
    else
        return 2
    fi
}

get_config_args(){
    local JsonFilePath=$1

    if [ ! -f $JsonFilePath ]; then
        echo "$NAME config file $JsonFilePath not found"
        exit 1
    fi

    if [ ! "$(command -v jq)" ]; then
        echo "Cannot find dependent package 'jq' Please use yum or apt to install and try again"
        exit 1
    fi

    # ref: https://stackoverflow.com/questions/53135035/jq-returning-null-as-string-if-the-json-is-empty
    # ref: https://github.com/stedolan/jq/issues/354#issuecomment-43147898
    NameServer=$(cat ${JsonFilePath} | jq -r '.nameserver // empty')
    [ -z "$NameServer" ] && echo -e "Configuration option 'nameserver' acquisition failed" && exit 1
}

do_status() {
    check_running
    case $? in
        0)
        echo "$NAME (pid $PID) is running."
        ;;
        1|2)
        echo "$NAME is stopped"
        RET_VAL=1
        ;;
    esac
}

do_start() {
    if check_running; then
        echo "$NAME (pid $PID) is already running."
        return 0
    fi
    ulimit -n 51200
    if $(grep -q 'nameserver' $CONF); then
        get_config_args $CONF
        nohup $DAEMON server -c $CONF --dns $NameServer -vvv > $LOG 2>&1 &
    else
        nohup $DAEMON server -c $CONF -vvv > $LOG 2>&1 &
    fi
    check_pid
    echo $get_pid > $PID_FILE
    if check_running; then
        echo "Starting $NAME success"
    else
        echo "Starting $NAME failed"
        RET_VAL=1
    fi
}

do_stop() {
    if check_running; then
        kill -9 $PID
        rm -f $PID_FILE
        echo "Stopping $NAME success"
    else
        echo "$NAME is stopped"
        RET_VAL=1
    fi
}

do_restart() {
    do_stop
    sleep 0.5
    do_start
}

case "$1" in
    start|stop|restart|status)
    do_$1
    ;;
    *)
    echo "Usage: $0 { start | stop | restart | status }"
    RET_VAL=1
    ;;
esac

exit $RET_VAL