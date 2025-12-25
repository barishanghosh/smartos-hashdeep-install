#!/bin/bash
#
# Fix compiler flags for hashdeep build on SmartOS
# Disables -Werror to allow -Weffc++ warnings
#

set -e

# Use GNU sed on SmartOS
SED="sed"
if command -v gsed &> /dev/null; then
    SED="gsed"
fi

HASHDEEP_DIR="/opt/hashdeep"
MAKEFILE_AM="${HASHDEEP_DIR}/src/Makefile.am"
MAKEFILE="${HASHDEEP_DIR}/src/Makefile"

if [ ! -f "$HASHDEEP_DIR/configure" ]; then
    echo "Error: Cannot find $HASHDEEP_DIR/configure"
    echo "Please ensure hashdeep source is in /opt/hashdeep"
    exit 1
fi

echo "Fixing compiler flags for SmartOS build..."

# Backup files
echo "Creating backups..."
if [ -f "$MAKEFILE_AM" ]; then
    cp "$MAKEFILE_AM" "${MAKEFILE_AM}.bak"
    echo "Backed up: ${MAKEFILE_AM}.bak"
fi

if [ -f "$MAKEFILE" ]; then
    cp "$MAKEFILE" "${MAKEFILE}.bak"
    echo "Backed up: ${MAKEFILE}.bak"
fi

echo ""
echo "Checking for -Werror flag..."
if grep -q "Werror" "$MAKEFILE" 2>/dev/null; then
    echo "Found -Werror in Makefile"

    # Remove -Werror from Makefile
    $SED -i.tmp 's/-Werror//g' "$MAKEFILE"
    echo "Removed -Werror from Makefile"
else
    echo "No -Werror found in Makefile"
fi

echo ""
echo "Checking for -Weffc++ flag..."
if grep -q "Weffc++" "$MAKEFILE" 2>/dev/null; then
    echo "Found -Weffc++ in Makefile"

    # Remove -Weffc++ from Makefile
    $SED -i.tmp2 's/-Weffc++//g' "$MAKEFILE"
    echo "Removed -Weffc++ from Makefile"
else
    echo "No -Weffc++ found in Makefile"
fi

echo ""
echo "Fix applied successfully."

