#!/bin/bash

# Usage:
# ./analyze_case.sh <case_number>

CASE_NUMBER="$1"

if [[ -z "$CASE_NUMBER" ]]; then
    echo "Usage: $0 <case_number>"
    exit 1
fi

BASE_PATH="path to sosreport"
CASE_DIR="$BASE_PATH/$CASE_NUMBER"

if [[ ! -d "$CASE_DIR" ]]; then
    echo "ERROR: Case directory not found:"
    echo "$CASE_DIR"
    exit 1
fi

echo

for OUTER_DIR in "$CASE_DIR"/*; do

    [[ ! -d "$OUTER_DIR" ]] && continue

    # Find actual sosreport directory
    SOS_DIR=$(find "$OUTER_DIR" -maxdepth 1 -type d -name "sosreport*" | head -1)

    [[ -z "$SOS_DIR" ]] && continue

    # Skip invalid sosreports
    [[ ! -f "$SOS_DIR/installed-rpms" ]] && continue

    # Hostname
    HOSTNAME=$(head -1 "$SOS_DIR/hostname" 2>/dev/null)

    # RHEL Version
    RHEL_VERSION=$(cat "$SOS_DIR/etc/redhat-release" 2>/dev/null)

    # Detect Capsule
    CAPSULE_VERSION=$(grep "^satellite-capsule-" \
        "$SOS_DIR/installed-rpms" | head -1)

    # Detect Satellite
    SATELLITE_VERSION=$(grep "^satellite-[0-9]" \
        "$SOS_DIR/installed-rpms" | head -1)

    # Capsule Output
    if [[ -n "$CAPSULE_VERSION" ]]; then

        echo "Environment:"
        echo
        echo "Capsule: $HOSTNAME"
        echo "$CAPSULE_VERSION"
        echo "$RHEL_VERSION"
        echo
        echo

    # Satellite Output
    elif [[ -n "$SATELLITE_VERSION" ]]; then

        echo "Environment:"
        echo
        echo "Satellite: $HOSTNAME"
        echo "$SATELLITE_VERSION"
        echo "$RHEL_VERSION"
        echo
        echo

    fi

done
