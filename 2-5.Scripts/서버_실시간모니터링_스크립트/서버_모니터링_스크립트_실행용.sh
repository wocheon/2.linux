#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
watch -t --color -n 2 "bash $SCRIPT_DIR/server_mon_org.sh"
