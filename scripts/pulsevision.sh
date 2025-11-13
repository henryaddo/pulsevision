#!/bin/bash
#PULSEVISION-oofline unified Dashboard Builder

set -euo pipefail
#=================================================
#FILE LOCATION
#=================================================

TEMPLATE="/opt/pulsevision/html/template.html"
OUTPUT_DIR="/var/www/html/pulsevision"
OUTPUT="$OUTPUT_DIR/index.html"

LOG_DIR="/opt/pulsevision/logs"
LOG="$LOG_DIR/pulsevision.log"

GRID_STATUS="/var/lib/pulsegrid/status.txt"
GUARD_STATUS="/var/lib/pulseguard/status.txt"
SAFE_STATUS="/var/lib/pulsesafe/status.txt"
AUDIT_STATUS="/var/lib/pulseaudit/status.txt"

#=========================================
#DIRECTORIES
#========================================
mkdir -p "$OUTPUT_DIR"
mkdir -p "$LOG_DIR"

#=========================================
#ENSURE LOG EXISTS
#=========================================
if [ ! -f "$LOG" ]; then
	touch "$LOG" 
	chmod 600 "$LOG"
	restorecon "$LOG"
fi

#=============================================
#ENSURE OUTPUT EXISTS
#=============================================

if [ ! -f "$OUTPUT" ]; then 
	touch "$OUTPUT"
	chmod 644 "$OUTPUT"
	restorecon "$OUTPUT"
fi

#==============================================
#ENSURE IF TEMPLATE EXISTS
#==============================================

if [ ! -f "$TEMPLATE" ]; then 
	echo " ERROR: Missing template:$TEMPLATE" |tee -a "$LOG"
	exit 1
fi

#===================================
#SAFE READ FUNTION 
#======================================

read_status(){
	local file="$1"
	if [ -f "$file" ]; then 
		tr -d '\r' < "$file" | xargs echo
	else
		echo "unknown"
	fi
}

#=======================================================
#LOAD VALUES
#=======================================================

DATE=$(date '+%F %T')
PULSEGRID=$(read_status "$GRID_STATUS")
PULSEGUARD=$(read_status "$GUARD_STATUS")
PULSESAFE=$(read_status "$SAFE_STATUS")
PULSEAUDIT=$(read_status "$AUDIT_STATUS")

GRID_SAFE=$(printf '%s' "$PULSEGRID")
GUARD_SAFE=$(printf '%s' "$PULSEGUARD")
SAFE_SAFE=$(printf '%s' "$PULSESAFE")
AUDIT_SAFE=$(printf '%s' "$PULSEAUDIT")

#==========================================================
#BUILD DASHBOARD
#=========================================================

sed -e "s|<!--TIME-->|$DATE|g" \
    -e "s|<!--PULSEGRID-->|<pre>${GRID_SAFE}</pre>|g" \
    -e "s|<!--PULSEGUARD-->|<pre>${GUARD_SAFE}</pre>|g" \
    -e "s|<!--PULSESAFE-->|<pre>${SAFE_SAFE}</pre>|g" \
    -e "s|<!--PULSEAUDIT-->|<pre>${AUDIT_SAFE}</pre>|g" \
    "$TEMPLATE" > "$OUTPUT"
echo "$DATE-Dashboard updated" >> "$LOG"
echo "Dashboard updated sucessfully."

