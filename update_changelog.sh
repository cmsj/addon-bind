#!/bin/bash

ADDON_DATA="VERSION"
BASE_DATA="upstream_docker_version.txt"
DEPS_DATA="upstream_latest_release.txt"
CHANGELOG="bind/CHANGELOG.md"
BREAKING="BREAKING.md"

if [ ! -e "${BASE_DATA}" ] || [ ! -e "${DEPS_DATA}" ]; then
    echo "ERROR: This script must be run with the top level of the repository as PWD"
    exit 1
fi

BASEIMG=$(cat "${BASE_DATA}" | awk '{ print $3 }')
BINDVER=$(cat "${DEPS_DATA}" | grep " bind " | sed -e 's/.*(\(.*\))/\1/')
DEPS=$(cat "${DEPS_DATA}" | grep -v " bind " | sed -e 's/.*Installing / \* /g' | sort)

echo -n "" >"${CHANGELOG}"
{
    if [ -e "${BREAKING}" ]; then
        echo "# Breaking change"
        echo ""
        cat "${BREAKING}"
        echo ""
    fi

    echo "# Version information"
    echo ""
    echo " * Addon version: $(cat "${ADDON_DATA}")"
    echo " * BIND version: ${BINDVER}"
    echo " * Home Assistant Add-on base image version: ${BASEIMG}"
    echo ""
    echo "Dependencies:"
    echo "${DEPS}"
} >> "${CHANGELOG}"

