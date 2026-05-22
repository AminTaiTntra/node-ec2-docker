# Node.js Server on AWS EC2

A simple Node.js Express server with Docker and Docker Compose setup for AWS EC2 deployment.

## Features

- Express.js REST API
- Docker containerization
- Docker Compose orchestration
- Health check endpoint
- Production-ready configuration

## Prerequisites

- Docker installed
- Docker Compose installed
- Node.js 20+ (for local development)

## Local Development

### Install dependencies
```bash
npm install
```

### Run locally (with nodemon for hot reload)
```bash
npm run dev
```

The server will be available at `http://localhost:3000`

## API Endpoints

- `GET /` - Welcome message
- `GET /health` - Health check
- `GET /api` - Server status information

## PM2 Process Management

### Start application with PM2
```bash
pm2 start ecosystem.config.js --env production
```

### Monitor application
```bash
pm2 monit
pm2 logs
pm2 status
```

### Restart/Stop application
```bash
pm2 restart all
pm2 stop all
pm2 delete all
```

## EC2 Deployment

### Quick Deployment (from GitHub)

See [GITHUB_EC2_SETUP.md](./GITHUB_EC2_SETUP.md) for complete instructions including:
- Setting up GitHub repository
- Connecting to EC2 via SSH
- Deploying application with PM2
- Auto-restart on EC2 reboot
- Continuous deployment options

### Prerequisites on EC2
The deployment script installs everything automatically:
- Node.js 20
- PM2 globally
- Project dependencies
- Auto-restart service

### Manual Deployment Steps

1. Clone repository on EC2:
```bash
git clone https://github.com/YOUR_USERNAME/node-aws-server.git
cd node-aws-server
```

2. Run deployment script:
```bash
bash deploy.sh
```

3. Verify deployment:
```bash
curl http://localhost:3000/health
pm2 status
```

### EC2 Security Group Settings

Open these ports in your Security Group:
- Port 3000 (application) - from your IP or 0.0.0.0/0
- Port 22 (SSH) - from your IP

### Monitor on EC2

```bash
# Check PM2 status
pm2 status

# View logs
pm2 logs

# Real-time monitoring
pm2 monit

# Restart application
pm2 restart all
```

## Environment Variables

Configure via `.env` file:

```
NODE_ENV=production
PORT=3000
```

## Troubleshooting

### Container exits immediately
```bash
docker-compose logs app
```

### Port already in use
```bash
docker ps
docker stop <container_id>
```

### Permission denied on EC2
Add user to docker group:
```bash
sudo usermod -a -G docker $USER
newgrp docker
```

## Performance Tips

1. Use Alpine Linux base image (keeps image size small)
2. Multi-stage builds for production
3. Health checks enabled
4. Proper logging and monitoring
5. Resource limits can be added to docker-compose.yml

## License

ISC
