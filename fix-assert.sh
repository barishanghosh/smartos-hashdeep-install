#!/bin/bash
#
# Fix hashdeep build on SmartOS - add missing assert.h include
# Patches common.h, main.cpp, and main.h
#

set -e

# Use GNU sed on SmartOS
SED="sed"
if command -v gsed &> /dev/null; then
    SED="gsed"
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HASHDEEP_SRC_DIR="/opt/hashdeep/src"
MAIN_CPP="${HASHDEEP_SRC_DIR}/main.cpp"
MAIN_H="${HASHDEEP_SRC_DIR}/main.h"
COMMON_H="${HASHDEEP_SRC_DIR}/common.h"

if [ ! -d "$HASHDEEP_SRC_DIR" ]; then
    echo "Error: Cannot find $HASHDEEP_SRC_DIR"
    echo "Please ensure hashdeep source is in /opt/hashdeep"
    exit 1
fi

echo "Fixing assert.h includes in hashdeep source files..."
echo ""

# Copy the SmartOS assert workaround header
if [ -f "$SCRIPT_DIR/smartos_assert.h" ]; then
    echo "Copying SmartOS assert workaround header..."
    cp "$SCRIPT_DIR/smartos_assert.h" "$HASHDEEP_SRC_DIR/"
    echo "smartos_assert.h copied to $HASHDEEP_SRC_DIR"
    echo ""
fi

# Function to add smartos_assert.h include to a file
add_assert_include() {
    local file="$1"
    local filename=$(basename "$file")

    if [ ! -f "$file" ]; then
        echo "Warning: $file not found, skipping"
        return
    fi

    # Backup original file
    if [ ! -f "${file}.orig" ]; then
        echo "Creating backup: ${file}.orig"
        cp "$file" "${file}.orig"
    fi

    # Check if smartos_assert.h is already included
    if grep -q '#include "smartos_assert.h"' "$file"; then
        echo "smartos_assert.h already included in $filename"
        return
    fi

    # Add smartos_assert.h include after assert.h
    echo "Adding smartos_assert.h include to $filename..."

    if grep -q "#include <assert.h>" "$file"; then
        # Add our header right after assert.h
        $SED -i.bak 's|#include <assert.h>|#include <assert.h>\
#include "smartos_assert.h"|' "$file"
        echo "Fixed $filename"
    else
        # Add both assert.h and our header after first include or header guard
        if [[ "$filename" == *.h ]]; then
            $SED -i.bak '/^#define.*_H$/a\
#include <assert.h>\
#include "smartos_assert.h"' "$file"
        else
            $SED -i.bak '0,/^#include/s||#include <assert.h>\
#include "smartos_assert.h"\
&|' "$file"
        fi
        echo "Fixed $filename"
    fi
}

# Fix all files that include assert.h
add_assert_include "$COMMON_H"
add_assert_include "$MAIN_CPP"
add_assert_include "$MAIN_H"
add_assert_include "${HASHDEEP_SRC_DIR}/xml.cpp"

echo ""
echo "Fix applied successfully."

