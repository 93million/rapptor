#! /usr/bin/env bash

COMPOSEFILE="$1"
CMD="$2"

usage()
{
  echo "$0 <compose-file-path> <start|stop|restart>"
}

if [ -x "$COMPOSEFILE" ]; then
  usage
  exit 1
fi

if [ "$CMD" != "start" ] && [ "$CMD" != "stop" ] && [ "$CMD" != "restart" ]; then
  usage
  exit 2
fi

if [ "$CMD" == "stop" ] || [ "$CMD" == "restart" ]; then
  docker compose -f "$COMPOSEFILE" down
fi

if [ "$CMD" == "start" ] || [ "$CMD" == "restart" ]; then
  docker compose -f "$COMPOSEFILE" up -d
fi
