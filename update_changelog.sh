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

OLD_BINDVER=$(cat "${CHANGELOG}" | grep "BIND version" | sed -e 's/^ \* BIND version: //')
OLD_BASEVER=$(cat "${CHANGELOG}" | grep "base image version" | sed -e 's/^.* image version: //')
OLD_DEPS=$(cat "${CHANGELOG}" | sed '1,/^Dependencies:$/d')

#echo -n "" >"${CHANGELOG}"
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

    echo -n " * BIND version: "
    if [ ${OLD_BINDVER} != ${BINDVER} ]; then
        echo "${OLD_BINDVER} -> ${BINDVER}"
    else
        echo "${BINDVER} (unchanged)"
    fi

    echo -n " * Home Assistant Add-on base image version: "
    if [ "${OLD_BASEVER}" != "${BASEIMG}" ]; then
        echo "${OLD_BASEVER} -> ${BASEIMG}"
    else
        echo "${BASEIMG} (unchanged)"
    fi

    echo ""
    echo "Dependencies:"

    # Arrays to track processed dependencies
    declare -a processed_old_deps=()
    declare -a removed_deps=()

    # Process each dependency to show version changes
    while IFS= read -r dep; do
        if [ -n "$dep" ]; then
            # Extract package name and version from current dependency
            # Format is "* package_name (version)"
            pkg_name=$(echo "$dep" | sed -e 's/ \* \([^(]*\) (.*)/\1/')
            pkg_version=$(echo "$dep" | sed -e 's/.*(\([^)]*\))/\1/')
            
            # Find corresponding old version
            old_dep_line=$(echo "$OLD_DEPS" | grep " \* $pkg_name (")
            if [ -n "$old_dep_line" ]; then
                old_version=$(echo "$old_dep_line" | sed -e 's/.*(\([^)]*\))/\1/')
                if [ "$old_version" != "$pkg_version" ]; then
                    echo " * $pkg_name: $old_version -> $pkg_version"
                else
                    echo " * $pkg_name: $pkg_version (unchanged)"
                fi
                # Mark this old dependency as processed
                processed_old_deps+=("$pkg_name")
            else
                # New dependency
                echo " * $pkg_name: $pkg_version (new)"
            fi
        fi
    done <<< "$DEPS"

    # Check for removed dependencies
    while IFS= read -r old_dep; do
        if [ -n "$old_dep" ]; then
            old_pkg_name=$(echo "$old_dep" | sed -e 's/ \* \([^(]*\) (.*)/\1/')
            old_pkg_version=$(echo "$old_dep" | sed -e 's/.*(\([^)]*\))/\1/')
            
            # Check if this old dependency is not in the processed list
            found=false
            for processed in "${processed_old_deps[@]}"; do
                if [ "$processed" = "$old_pkg_name" ]; then
                    found=true
                    break
                fi
            done
            
            if [ "$found" = false ]; then
                removed_deps+=("$old_pkg_name:$old_pkg_version")
            fi
        fi
    done <<< "$OLD_DEPS"

    # Report removed dependencies
    for removed in "${removed_deps[@]}"; do
        pkg_name=$(echo "$removed" | cut -d: -f1)
        pkg_version=$(echo "$removed" | cut -d: -f2)
        echo " * $pkg_name: $pkg_version (removed)"
    done
}
#>> "${CHANGELOG}"

