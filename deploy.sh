#!/bin/bash

# EC2 Startup Script for Node.js Application with PM2
# Run on EC2: bash deploy.sh
# Supports: Amazon Linux, Ubuntu, Debian, CentOS, RHEL

set -e

echo "=== Node.js Server EC2 Deployment with PM2 ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect package manager and OS
if command -v apt-get &> /dev/null; then
    # Ubuntu/Debian
    PKG_MANAGER="apt"
    UPDATE_CMD="sudo apt-get update"
    INSTALL_CMD="sudo apt-get install -y"
    OS_TYPE="debian"
elif command -v yum &> /dev/null; then
    # Amazon Linux, CentOS, RHEL
    PKG_MANAGER="yum"
    UPDATE_CMD="sudo yum update -y"
    INSTALL_CMD="sudo yum install -y"
    OS_TYPE="rhel"
else
    echo -e "${RED}✗ Unsupported OS. Neither apt nor yum found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Detected OS: $OS_TYPE (using $PKG_MANAGER)${NC}"

# Update system
echo -e "${YELLOW}Updating system packages...${NC}"
eval $UPDATE_CMD

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}Node.js not found. Installing...${NC}"
    
    if [ "$OS_TYPE" = "debian" ]; then
        # Ubuntu/Debian
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    else
        # Amazon Linux, CentOS, RHEL
        curl -sL https://rpm.nodesource.com/setup_18.x | sudo bash -
        sudo yum install -y nodejs
    fi
fi

echo -e "${GREEN}✓ Node.js $(node -v) installed${NC}"

# Check if PM2 is installed globally
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}PM2 not found. Installing globally...${NC}"
    sudo npm install -g pm2
    sudo pm2 startup systemd -u $(whoami) --hp $HOME
fi

echo -e "${GREEN}✓ PM2 installed${NC}"

# Ensure curl is installed (needed for health check)
if ! command -v curl &> /dev/null; then
    echo -e "${YELLOW}Installing curl...${NC}"
    eval "$INSTALL_CMD curl"
fi

# Create project directory if it doesn't exist
PROJECT_DIR="$HOME/node-aws-server"
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}Creating project directory at $PROJECT_DIR...${NC}"
    mkdir -p "$PROJECT_DIR"
fi

# Navigate to project directory
cd "$PROJECT_DIR"

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ .env file created${NC}"
fi

# Install dependencies
echo -e "${YELLOW}Installing dependencies...${NC}"
npm ci --omit=dev

# Create logs directory
mkdir -p logs

# Start/restart application with PM2
echo -e "${YELLOW}Starting application with PM2...${NC}"
pm2 start ecosystem.config.js --env production
pm2 save

# Wait for service to be ready
echo -e "${YELLOW}Waiting for service to be ready...${NC}"
sleep 3

# Health check
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Service is healthy${NC}"
    echo -e "${GREEN}✓ Application is running at http://localhost:3000${NC}"
else
    echo -e "${RED}✗ Service health check failed${NC}"
    pm2 logs
    exit 1
fi

echo -e "${GREEN}=== Deployment Complete ===${NC}"
echo -e "${YELLOW}Useful PM2 commands:${NC}"
echo "  View logs: pm2 logs"
echo "  Monitor: pm2 monit"
echo "  Status: pm2 status"
echo "  Stop: pm2 stop all"
echo "  Restart: pm2 restart all"
echo "  Delete app: pm2 delete all"
