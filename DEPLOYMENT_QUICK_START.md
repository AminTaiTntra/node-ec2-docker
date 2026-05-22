# Quick Start: Push to GitHub & Deploy to EC2

## Phase 1: Push to GitHub (Local Machine)

```bash
# 1. Navigate to project directory
cd /home/tntra/Desktop/projects/node-ece-aws

# 2. Initialize git
git init
git add .
git commit -m "Initial commit: Node.js server with PM2 setup for EC2"

# 3. Go to GitHub and create new repository
# https://github.com/new
# Name it: node-aws-server
# Don't initialize with README
# Copy the repo URL

# 4. Add remote and push (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/node-aws-server.git
git branch -M main
git push -u origin main

# ✓ Now your code is on GitHub!
```

## Phase 2: Connect to EC2 (SSH)

```bash
# Get your EC2 public IP from AWS Console
# (EC2 → Instances → Select your instance → Copy Public IPv4 address)

# SSH into EC2 (replace with your IP)
ssh -i /path/to/your-key.pem ec2-user@YOUR_EC2_PUBLIC_IP

# You should now see: [ec2-user@ip-xxx-xxx-xxx-xxx ~]$

# Optional: Check your system setup
bash check-system.sh
```

## Phase 3: Clone & Deploy on EC2

```bash
# On EC2 instance, run these commands:

# 1. Clone the repository (replace YOUR_USERNAME)
git clone https://github.com/YOUR_USERNAME/node-aws-server.git
cd node-aws-server

# 2. Run the deployment script
bash deploy.sh

# The script will:
# ✓ Install Node.js 20
# ✓ Install PM2
# ✓ Install dependencies
# ✓ Start the app
# ✓ Verify health check

# Wait for: "Deployment Complete"
```

## Phase 4: Verify it's Working

```bash
# On EC2 instance:

# 1. Check status
pm2 status

# 2. Test the application
curl http://localhost:3000/health
curl http://localhost:3000/api

# 3. View logs
pm2 logs

# 4. Real-time monitor
pm2 monit
```

## Phase 5: Access from Browser

```bash
# On your local machine, open browser:
http://YOUR_EC2_PUBLIC_IP:3000

# You should see: {"message":"Welcome to Node.js AWS Server"}
```

## Common Commands on EC2

```bash
# View application status
pm2 status

# View logs
pm2 logs

# Restart application
pm2 restart all

# Stop application
pm2 stop all

# View real-time monitoring
pm2 monit

# Update application from GitHub
cd ~/node-aws-server
bash update.sh
```

## Troubleshooting

### "yum: command not found" or Package Manager Issues
- Run: `bash check-system.sh` to see your OS
- The `deploy.sh` script automatically detects apt vs yum
- Works on: Ubuntu, Debian, Amazon Linux, CentOS, RHEL

### "Connection refused"
- Check security group allows port 3000
- Verify application is running: `pm2 status`

### "git: command not found"
- Already installed by deploy script
- Manual install (Ubuntu): `sudo apt-get install -y git`
- Manual install (Amazon Linux): `sudo yum install -y git`

### "pm2: command not found"
- Re-run: `sudo npm install -g pm2`

### Port 3000 already in use
- Check: `lsof -i :3000`
- Kill process: `sudo kill -9 <PID>`

## Next Time You Update

```bash
# On EC2:
cd ~/node-aws-server
bash update.sh

# This will:
# ✓ Pull latest from GitHub
# ✓ Install new dependencies
# ✓ Restart with PM2
```

## EC2 Reboot?

PM2 is configured to auto-start on reboot. After EC2 restarts, your app will automatically start!

## Need Full Details?

See [GITHUB_EC2_SETUP.md](./GITHUB_EC2_SETUP.md) for comprehensive guide including:
- SSH key setup
- PM2 essentials
- Continuous deployment
- Troubleshooting
