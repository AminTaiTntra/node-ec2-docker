#!/bin/bash

# EC2 Startup Script for Node.js Application with PM2
# Run on EC2: bash deploy.sh

set -e

echo "=== Node.js Server EC2 Deployment with PM2 ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Update system
echo -e "${YELLOW}Updating system packages...${NC}"
sudo yum update -y

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}Node.js not found. Installing...${NC}"
    curl -sL https://rpm.nodesource.com/setup_18.x | sudo bash -
    sudo yum install -y nodejs
fi

echo -e "${GREEN}✓ Node.js $(node -v) installed${NC}"

# Check if PM2 is installed globally
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}PM2 not found. Installing globally...${NC}"
    sudo npm install -g pm2
    sudo pm2 startup systemd -u ec2-user --hp /home/ec2-user
fi

echo -e "${GREEN}✓ PM2 installed${NC}"

# Create project directory if it doesn't exist
PROJECT_DIR="/home/ec2-user/node-aws-server"
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}Creating project directory...${NC}"
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
