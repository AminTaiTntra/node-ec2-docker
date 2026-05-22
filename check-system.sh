#!/bin/bash

# System Detection Script
# Run this on EC2 to check OS and available tools

echo "=== EC2 System Information ==="

echo ""
echo "OS Information:"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "  OS: $NAME"
    echo "  Version: $VERSION"
    echo "  ID: $ID"
else
    uname -a
fi

echo ""
echo "Package Manager:"
if command -v apt-get &> /dev/null; then
    echo "  ✓ apt-get (Debian/Ubuntu)"
    apt --version
elif command -v yum &> /dev/null; then
    echo "  ✓ yum (Amazon Linux/CentOS/RHEL)"
    yum --version
else
    echo "  ✗ No package manager found"
fi

echo ""
echo "Node.js:"
if command -v node &> /dev/null; then
    echo "  ✓ Installed: $(node --version)"
else
    echo "  ✗ Not installed"
fi

echo ""
echo "PM2:"
if command -v pm2 &> /dev/null; then
    echo "  ✓ Installed: $(pm2 --version)"
else
    echo "  ✗ Not installed"
fi

echo ""
echo "Other tools:"
command -v git &> /dev/null && echo "  ✓ git" || echo "  ✗ git"
command -v curl &> /dev/null && echo "  ✓ curl" || echo "  ✗ curl"
command -v wget &> /dev/null && echo "  ✓ wget" || echo "  ✗ wget"

echo ""
echo "Current User:"
echo "  User: $(whoami)"
echo "  Home: $HOME"

echo ""
echo "If you're missing yum, this is likely Ubuntu/Debian."
echo "The deploy.sh script will automatically detect and use apt-get."
