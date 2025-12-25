#!/bin/bash
#
# Fix algorithm_t default constructor issue on SmartOS
#

set -e

# Use GNU sed on SmartOS
SED="sed"
if command -v gsed &> /dev/null; then
    SED="gsed"
fi

HASHDEEP_SRC="/opt/hashdeep/src/main.cpp"

if [ ! -f "$HASHDEEP_SRC" ]; then
    echo "Error: Cannot find $HASHDEEP_SRC"
    echo "Please ensure hashdeep source is in /opt/hashdeep"
    exit 1
fi

echo "Searching for algorithm_t hashes array declaration..."

# Backup
if [ ! -f "${HASHDEEP_SRC}.bak2" ]; then
    echo "Creating backup: ${HASHDEEP_SRC}.bak2"
    cp "$HASHDEEP_SRC" "${HASHDEEP_SRC}.bak2"
fi

# Check if already fixed first
if grep -q "hashes\[NUM_ALGORITHMS\] = {};" "$HASHDEEP_SRC"; then
    echo "Array already uses value initialization"
    echo ""
    echo "Fix complete. Now rebuild:"
    echo "  cd /opt/hashdeep"
    echo "  gmake clean"
    echo "  gmake"
    exit 0
fi

# Find the line number with the hashes array declaration (unfixed version)
LINE_NUM=$(grep -n "algorithm_t.*hashes\[NUM_ALGORITHMS\];" "$HASHDEEP_SRC" | cut -d: -f1)

if [ -z "$LINE_NUM" ]; then
    echo "Error: Could not find 'algorithm_t hashes[NUM_ALGORITHMS];' declaration"
    echo ""
    echo "Searching for similar patterns..."
    grep -n "hashes\[NUM_ALGORITHMS\]" "$HASHDEEP_SRC" || echo "No matches found"
    exit 1
fi

echo "Found array declaration at line: $LINE_NUM"
echo "Current line content:"
$SED -n "${LINE_NUM}p" "$HASHDEEP_SRC"
echo ""

# Apply the fix
echo "Applying fix: Adding value initialization..."
$SED -i.bak3 "${LINE_NUM}s/hashes\[NUM_ALGORITHMS\];/hashes[NUM_ALGORITHMS] = {};/" "$HASHDEEP_SRC"

echo "Fix applied successfully!"
echo ""
echo "New line content:"
$SED -n "${LINE_NUM}p" "$HASHDEEP_SRC"

echo ""
echo "Fix complete."

