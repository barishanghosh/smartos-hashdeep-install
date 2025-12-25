#!/bin/bash
#
# Build hashdeep with all SmartOS fixes applied
# Assumes hashdeep source is already in /opt/hashdeep
# and this script is run from the smartos-hashdeep-install directory
#

set -e

# Configuration
HASHDEEP_DIR="/opt/hashdeep"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"


print_status() {
    echo -e "$1"
}

print_error() {
    echo -e "ERROR: $1"
}

echo "================================================================"
echo "  hashdeep build script for SmartOS"
echo "================================================================"
echo ""

# Check if hashdeep source exists
if [ ! -d "$HASHDEEP_DIR" ]; then
    print_error "hashdeep source not found at $HASHDEEP_DIR"
    echo "Please download and extract hashdeep first:"
    echo "  cd /opt"
    echo "  git clone --branch release-4.4 https://github.com/jessek/hashdeep.git"
    echo "  cd hashdeep"
    echo "  ./bootstrap.sh (if building from git)"
    echo "  ./configure"
    exit 1
fi

# Check if configure has been run
if [ ! -f "$HASHDEEP_DIR/Makefile" ]; then
    print_error "hashdeep not configured. Please run:"
    echo "  cd $HASHDEEP_DIR"
    echo "  ./configure"
    exit 1
fi

# Apply fixes
cd "$SCRIPT_DIR"

print_status "Applying Fix 1/4: assert.h includes..."
./fix-assert.sh

print_status "Applying Fix 2/4: algorithm_t initialization..."
./fix-algorithm_t.sh

print_status "Applying Fix 3/4: compiler flags..."
./fix-compiler-flags.sh

print_status "Applying Fix 4/4: C++11 literal spacing..."
./fix-cpp11-literals.sh

# Build
print_status "Building hashdeep..."
cd "$HASHDEEP_DIR"
gmake clean
gmake

print_status "Installing hashdeep..."
gmake install

# Verify
echo ""
print_status "Verifying installation..."
if command -v hashdeep &> /dev/null; then
    echo -e "Build and installation successful."
    echo ""
    hashdeep -V
else
    print_error "Installation verification failed"
    exit 1
fi
