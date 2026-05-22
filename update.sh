#!/bin/bash

# EC2 Update Script - Pull latest from GitHub and restart with PM2
# Run on EC2: bash update.sh

set -e

echo "=== Updating Application from GitHub ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Set project directory dynamically to the directory containing the script
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$PROJECT_DIR"

echo -e "${YELLOW}Current branch and status:${NC}"
git status

echo -e "${YELLOW}Pulling latest changes from GitHub...${NC}"
git pull origin main

echo -e "${YELLOW}Installing dependencies...${NC}"
npm ci --omit=dev

echo -e "${YELLOW}Restarting application...${NC}"
pm2 restart all

# Wait for service to be ready
sleep 2

# Health check
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Update successful${NC}"
    echo -e "${GREEN}✓ Application is running${NC}"
    pm2 status
else
    echo -e "${RED}✗ Service health check failed${NC}"
    pm2 logs
    exit 1
fi

echo -e "${GREEN}=== Update Complete ===${NC}"
