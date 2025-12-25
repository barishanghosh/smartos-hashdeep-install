#!/bin/bash
#
# Fix C++11 literal spacing issues in hashdeep source
# Required for modern compilers (clang/gcc with C++11)
#

set -e

# Use GNU sed on SmartOS
SED="sed"
if command -v gsed &> /dev/null; then
    SED="gsed"
fi

HASHDEEP_SRC_DIR="/opt/hashdeep/src"

if [ ! -d "$HASHDEEP_SRC_DIR" ]; then
    echo "Error: Cannot find $HASHDEEP_SRC_DIR"
    echo "Please ensure hashdeep source is in /opt/hashdeep"
    exit 1
fi

echo "Fixing C++11 literal spacing in hashdeep source files..."
echo "=========================================================="
echo ""

cd "$HASHDEEP_SRC_DIR"

# Fix all C++ files and headers for PRI macros
echo "Processing source files..."
for file in *.cpp *.h; do
    if [ -f "$file" ]; then
        # Backup if not already backed up
        if [ ! -f "${file}.cpp11.bak" ]; then
            cp "$file" "${file}.cpp11.bak"
        fi

        # Fix PRId64, PRIu64, PRIu32, etc - add space between closing " and PRI
        # Pattern: "%" immediately followed by PRIxNN (no space) -> "%" PRIxNN
        $SED -i 's/"\(PRI[diuxX][0-9][0-9]*\)/" \1/g' "$file"

        echo "Fixed $file"
    fi
done

# Fix hash.cpp pointer comparison (if needed)
if [ -f "hash.cpp" ]; then
    if grep -q "fdht->base>0" hash.cpp; then
        echo ""
        echo "Fixing pointer comparison in hash.cpp..."
        $SED -i 's/if(fdht->base>0)/if(fdht->base!=MAP_FAILED \&\& fdht->base!=NULL)/g' hash.cpp
        echo "Fixed pointer comparison"
    fi
fi

echo ""
echo "Fix applied successfully."

