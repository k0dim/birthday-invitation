#!/bin/bash
set -e
ACTION="$1"  # start | stop | restart
TARGET="$2"  # app_blue | app_green

if [ "$ACTION" = "start" ]; then
  docker start $TARGET
elif [ "$ACTION" = "stop" ]; then
  docker stop $TARGET
elif [ "$ACTION" = "restart" ]; then
  docker restart $TARGET
else
  echo "Usage: $0 {start|stop|restart} {app_blue|app_green}"
  exit 1
fi
