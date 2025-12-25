#!/bin/bash
#
# Installation script for hashdeep on SmartOS Global Zone
# This script downloads hashdeep, applies all necessary fixes, and compiles it
#

set -e

# Configuration
INSTALL_DIR="/opt"
HASHDEEP_VERSION="4.4"
HASHDEEP_REPO="https://github.com/jessek/hashdeep.git"
FIXES_REPO="https://github.com/codevsm/smartos-hashdeep-install.git"
HASHDEEP_DIR="${INSTALL_DIR}/hashdeep"
FIXES_DIR="${INSTALL_DIR}/smartos-hashdeep-install"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================================"
echo "  hashdeep Installation Script for SmartOS Global Zone"
echo "================================================================"
echo ""

# Function to print colored messages
print_status() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    print_error "This script must be run as root"
    exit 1
fi

# Check prerequisites
print_status "Checking prerequisites..."

if ! command -v gcc &> /dev/null; then
    print_warning "gcc not found. Installing build tools..."
    pkgin -y install gcc gmake automake autoconf libtool git
else
    print_status "Build tools already installed"
fi

if ! command -v git &> /dev/null; then
    print_warning "git not found. Installing git..."
    pkgin -y install git
fi

# Clean up old installations if they exist
if [ -d "$HASHDEEP_DIR" ]; then
    print_warning "Removing existing hashdeep directory..."
    rm -rf "$HASHDEEP_DIR"
fi

if [ -d "$FIXES_DIR" ]; then
    print_warning "Removing existing fixes directory..."
    rm -rf "$FIXES_DIR"
fi

# Clone hashdeep repository
print_status "Cloning hashdeep repository..."
cd "$INSTALL_DIR"
git clone --branch "release-${HASHDEEP_VERSION}" "$HASHDEEP_REPO" hashdeep
if [ $? -ne 0 ]; then
    print_error "Failed to clone hashdeep repository"
    exit 1
fi

# Clone fixes repository
print_status "Cloning SmartOS fixes repository..."
git clone "$FIXES_REPO" smartos-hashdeep-install
if [ $? -ne 0 ]; then
    print_error "Failed to clone fixes repository"
    exit 1
fi

# Configure hashdeep
print_status "Configuring hashdeep..."
cd "$HASHDEEP_DIR"

# Bootstrap if needed (for git versions)
if [ -f "bootstrap.sh" ]; then
    print_status "Running bootstrap..."
    chmod +x bootstrap.sh
    bash bootstrap.sh
fi

# Run configure with prefix for writable location on SmartOS
if [ -f "configure" ]; then
    print_status "Running configure..."
    chmod +x configure
    ./configure --prefix=/opt/local
else
    print_error "configure script not found"
    exit 1
fi

# Apply fixes
print_status "Applying Fix 1/4: assert.h includes..."
cd "$FIXES_DIR"
chmod +x fix-assert.sh
./fix-assert.sh
if [ $? -ne 0 ]; then
    print_error "Failed to apply assert.h fix"
    exit 1
fi

print_status "Applying Fix 2/4: algorithm_t initialization..."
chmod +x fix-algorithm_t.sh
./fix-algorithm_t.sh
if [ $? -ne 0 ]; then
    print_error "Failed to apply algorithm_t fix"
    exit 1
fi

print_status "Applying Fix 3/4: compiler flags..."
chmod +x fix-compiler-flags.sh
./fix-compiler-flags.sh
if [ $? -ne 0 ]; then
    print_error "Failed to apply compiler flags fix"
    exit 1
fi

print_status "Applying Fix 4/4: C++11 literal spacing..."
chmod +x fix-cpp11-literals.sh
./fix-cpp11-literals.sh
if [ $? -ne 0 ]; then
    print_error "Failed to apply C++11 literal fix"
    exit 1
fi

# Build hashdeep
print_status "Building hashdeep..."
cd "$HASHDEEP_DIR"
gmake clean
gmake
if [ $? -ne 0 ]; then
    print_error "Build failed"
    exit 1
fi

# Install hashdeep
print_status "Installing hashdeep..."
gmake install
if [ $? -ne 0 ]; then
    print_error "Installation failed"
    exit 1
fi

# Verify installation
print_status "Verifying installation..."
echo ""
if command -v hashdeep &> /dev/null; then
    echo -e "hashdeep installed successfully."
    echo ""
    echo "Installed tools:"
    echo "  - hashdeep:      $(which hashdeep)"
    echo "  - md5deep:       $(which md5deep)"
    echo "  - sha1deep:      $(which sha1deep)"
    echo "  - sha256deep:    $(which sha256deep)"
    echo ""
    echo "Version information:"
    hashdeep -V
else
    print_error "hashdeep installation verification failed"
    exit 1
fi

echo ""
echo "================================================================"
echo -e "Installation completed."
echo "================================================================"
echo ""
echo "Usage examples:"
echo "  hashdeep -r /path/to/directory       # Recursive hash"
echo "  md5deep file.txt                     # MD5 hash of file"
echo "  sha256deep -r /path                  # SHA-256 recursive"
echo ""
echo "Source directories preserved at:"
echo "  - hashdeep:  $HASHDEEP_DIR"
echo "  - fixes:     $FIXES_DIR"
echo ""
