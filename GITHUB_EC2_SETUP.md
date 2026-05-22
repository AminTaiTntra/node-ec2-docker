# GitHub Setup & EC2 Deployment Guide

## Step 1: Initialize Git Repository Locally

```bash
cd /home/tntra/Desktop/projects/node-ece-aws

# Initialize git
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Node.js server with PM2 setup for EC2"
```

## Step 2: Create GitHub Repository

1. Go to https://github.com/new
2. Create a new repository (e.g., `node-aws-server`)
3. **DO NOT** initialize with README (we already have one)
4. Copy the repository URL

## Step 3: Push to GitHub

```bash
# Add remote (replace with your repo URL)
git remote add origin https://github.com/YOUR_USERNAME/node-aws-server.git

# Rename branch to main (if needed)
git branch -M main

# Push to GitHub
git push -u origin main
```

## Step 4: Connect to EC2

### A. SSH Setup

```bash
# From your local machine, copy your EC2 key if needed
# (If you already have the key pair from AWS)

# SSH into EC2 instance
ssh -i /path/to/your-key.pem ec2-user@YOUR_EC2_PUBLIC_IP
```

**Finding your EC2 public IP:**
- Go to AWS Console → EC2 → Instances
- Select your instance and note the "Public IPv4 address"

### B. Set Up SSH Key on EC2 (if using GitHub Deploy)

```bash
# On EC2 instance
ssh-keygen -t ed25519 -C "your-ec2-instance"
# Press Enter for all prompts

# Display public key
cat ~/.ssh/id_ed25519.pub

# Copy the output and add it to GitHub:
# Settings → SSH and GPG keys → New SSH key
```

## Step 5: Clone Repository on EC2

```bash
# On EC2 instance
cd /home/ec2-user

# Clone using HTTPS (simpler if SSH not set up)
git clone https://github.com/YOUR_USERNAME/node-aws-server.git
cd node-aws-server

# Or clone using SSH (if SSH key is set up)
git clone git@github.com:YOUR_USERNAME/node-aws-server.git
cd node-aws-server
```

## Step 6: Run Deployment Script on EC2

```bash
# On EC2 instance (from project directory)
bash deploy.sh
```

The script will:
- ✓ Install Node.js 18
- ✓ Install PM2 globally
- ✓ Install project dependencies
- ✓ Create .env file
- ✓ Start the application
- ✓ Verify health check

## Step 7: Verify Deployment

```bash
# Check PM2 status
pm2 status

# View logs
pm2 logs

# Monitor in real-time
pm2 monit

# Test health endpoint
curl http://localhost:3000/health

# Test API
curl http://localhost:3000/api
```

## EC2 Security Group Configuration

Ensure your EC2 Security Group allows:

**Inbound Rules:**
- SSH (port 22) - from your IP
- HTTP (port 80) - from 0.0.0.0/0 (optional)
- HTTP (port 3000) - from your IP or 0.0.0.0/0
- HTTPS (port 443) - from 0.0.0.0/0 (if using ALB/CloudFront)

## PM2 Essentials

### Useful Commands

```bash
# Start application
pm2 start ecosystem.config.js --env production

# Restart application
pm2 restart all

# Stop application
pm2 stop all

# Delete application
pm2 delete all

# View logs
pm2 logs

# View real-time monitoring
pm2 monit

# Save PM2 list
pm2 save

# Resurrect saved list
pm2 resurrect

# Check startup script
pm2 startup

# Update application from GitHub
cd ~/node-aws-server
git pull origin main
npm ci --omit=dev
pm2 restart all
```

### Auto-restart on Reboot

```bash
# This command sets up PM2 to start on system reboot
sudo pm2 startup systemd -u ec2-user --hp /home/ec2-user
pm2 save
```

## Continuous Deployment (Optional)

### Using PM2+ (Paid)

1. Create account at https://app.pm2.io
2. Link your EC2 instance to PM2+
3. Deploy from GitHub with one command

### Using GitHub Actions (Free)

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to EC2

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Deploy to EC2
        env:
          EC2_KEY: ${{ secrets.EC2_PRIVATE_KEY }}
          EC2_HOST: ${{ secrets.EC2_HOST }}
          EC2_USER: ec2-user
        run: |
          mkdir -p ~/.ssh
          echo "$EC2_KEY" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST "cd ~/node-aws-server && git pull origin main && npm ci --omit=dev && pm2 restart all"
```

Then add secrets to GitHub:
- `EC2_PRIVATE_KEY` - Your EC2 key pair private key
- `EC2_HOST` - Your EC2 public IP

## Troubleshooting

### Application won't start
```bash
pm2 logs
# Check the error logs
```

### Port 3000 already in use
```bash
lsof -i :3000
sudo kill -9 <PID>
```

### Git authentication issues
```bash
# Use HTTPS with personal access token
git remote set-url origin https://YOUR_TOKEN@github.com/USERNAME/node-aws-server.git
```

### PM2 not auto-starting
```bash
sudo pm2 startup systemd -u ec2-user --hp /home/ec2-user
pm2 save
sudo systemctl restart pm2-ec2-user
```

## Next Steps

1. **Monitor with CloudWatch** - Set up AWS CloudWatch alarms
2. **Use Load Balancer** - Add AWS Application Load Balancer in front
3. **Add HTTPS** - Use AWS Certificate Manager + ALB
4. **Auto-scaling** - Use EC2 Auto Scaling Group
5. **Database** - Connect to RDS instance if needed
