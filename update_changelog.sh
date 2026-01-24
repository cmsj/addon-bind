#!/bin/bash

ADDON_DATA="VERSION"
BASE_DATA="upstream_docker_version.txt"
DEPS_DATA="upstream_latest_release.txt"
CHANGELOG="bind/CHANGELOG.md"
BREAKING="BREAKING.md"
STATE_FILE="dependency_state.txt"

if [ ! -e "${BASE_DATA}" ] || [ ! -e "${DEPS_DATA}" ]; then
    echo "ERROR: This script must be run with the top level of the repository as PWD"
    exit 1
fi

# Parse new values from upstream data
BASEIMG=$(awk '{ print $3 }' "${BASE_DATA}")
BINDVER=$(grep " bind " "${DEPS_DATA}" | sed -e 's/.*(\(.*\))/\1/')

# Build list of new dependencies (format: pkg_name=version, one per line)
NEW_DEPS=$(grep "Installing" "${DEPS_DATA}" | grep -v " bind " | \
    sed -e 's/.*Installing \([^ ]*\) (\([^)]*\))/\1=\2/' | sort)

# Read old state from state file (if it exists)
OLD_BINDVER=""
OLD_BASEVER=""
OLD_DEPS=""

if [ -e "${STATE_FILE}" ]; then
    OLD_BINDVER=$(grep "^BIND_VERSION=" "${STATE_FILE}" | cut -d= -f2)
    OLD_BASEVER=$(grep "^BASE_IMAGE=" "${STATE_FILE}" | cut -d= -f2)
    OLD_DEPS=$(grep "^DEP:" "${STATE_FILE}" | sed 's/^DEP://' | sort)
fi

# Function to get version for a package from a deps list
get_version() {
    local pkg="$1"
    local deps="$2"
    echo "$deps" | grep "^${pkg}=" | cut -d= -f2
}

# Function to get package name from a line
get_pkg_name() {
    echo "$1" | cut -d= -f1
}

# Categorize dependencies
changed_deps=""
new_deps=""
removed_deps=""
unchanged_deps=""

# Check new/changed dependencies
while IFS= read -r line; do
    if [ -n "$line" ]; then
        pkg_name=$(get_pkg_name "$line")
        pkg_version=$(echo "$line" | cut -d= -f2)
        old_version=$(get_version "$pkg_name" "$OLD_DEPS")

        if [ -n "$old_version" ]; then
            if [ "$old_version" != "$pkg_version" ]; then
                changed_deps="${changed_deps}${pkg_name}:${old_version}:${pkg_version}"$'\n'
            else
                unchanged_deps="${unchanged_deps}${pkg_name}:${pkg_version}"$'\n'
            fi
        else
            new_deps="${new_deps}${pkg_name}:${pkg_version}"$'\n'
        fi
    fi
done <<< "$NEW_DEPS"

# Check for removed dependencies
while IFS= read -r line; do
    if [ -n "$line" ]; then
        pkg_name=$(get_pkg_name "$line")
        pkg_version=$(echo "$line" | cut -d= -f2)
        new_version=$(get_version "$pkg_name" "$NEW_DEPS")

        if [ -z "$new_version" ]; then
            removed_deps="${removed_deps}${pkg_name}:${pkg_version}"$'\n'
        fi
    fi
done <<< "$OLD_DEPS"

# Generate changelog
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
    if [ -n "$OLD_BINDVER" ] && [ "$OLD_BINDVER" != "$BINDVER" ]; then
        echo "$OLD_BINDVER -> $BINDVER"
    else
        echo "$BINDVER (unchanged)"
    fi

    echo -n " * Home Assistant Add-on base image version: "
    if [ -n "$OLD_BASEVER" ] && [ "$OLD_BASEVER" != "$BASEIMG" ]; then
        echo "$OLD_BASEVER -> $BASEIMG"
    else
        echo "$BASEIMG (unchanged)"
    fi

    echo ""
    echo "Changed Dependencies:"

    has_changes=false

    # Output changed dependencies
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            has_changes=true
            pkg_name=$(echo "$line" | cut -d: -f1)
            old_version=$(echo "$line" | cut -d: -f2)
            new_version=$(echo "$line" | cut -d: -f3)
            echo " * $pkg_name: $old_version -> $new_version"
        fi
    done <<< "$changed_deps"

    # Output new dependencies
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            has_changes=true
            pkg_name=$(echo "$line" | cut -d: -f1)
            pkg_version=$(echo "$line" | cut -d: -f2)
            echo " * $pkg_name: $pkg_version (new)"
        fi
    done <<< "$new_deps"

    # Output removed dependencies
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            has_changes=true
            pkg_name=$(echo "$line" | cut -d: -f1)
            pkg_version=$(echo "$line" | cut -d: -f2)
            echo " * $pkg_name: $pkg_version (removed)"
        fi
    done <<< "$removed_deps"

    if [ "$has_changes" = false ]; then
        echo " * None"
    fi

    echo ""
    echo "Unchanged Dependencies:"

    has_unchanged=false
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            has_unchanged=true
            pkg_name=$(echo "$line" | cut -d: -f1)
            pkg_version=$(echo "$line" | cut -d: -f2)
            echo " * $pkg_name: $pkg_version"
        fi
    done <<< "$unchanged_deps"

    if [ "$has_unchanged" = false ]; then
        echo " * None"
    fi
} > "${CHANGELOG}"

# Update state file with current values
{
    echo "BIND_VERSION=$BINDVER"
    echo "BASE_IMAGE=$BASEIMG"
    echo "$NEW_DEPS" | while IFS= read -r line; do
        if [ -n "$line" ]; then
            echo "DEP:$line"
        fi
    done
} > "${STATE_FILE}"
