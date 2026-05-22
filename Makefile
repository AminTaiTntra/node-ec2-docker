.PHONY: help install dev start stop logs build clean health monit restart

help:
	@echo "Node.js AWS Server with PM2 - Makefile Commands"
	@echo "================================================"
	@echo "  make install    - Install dependencies"
	@echo "  make dev        - Run in development mode with hot reload"
	@echo "  make start      - Start application with PM2"
	@echo "  make stop       - Stop application"
	@echo "  make logs       - View application logs"
	@echo "  make monit      - Monitor application in real-time"
	@echo "  make health     - Check service health"
	@echo "  make clean      - Remove all PM2 processes"
	@echo "  make restart    - Restart application"
	@echo "  make status     - Show PM2 status"

install:
	npm install

dev:
	npm run dev

start:
	pm2 start ecosystem.config.js --env production
	@echo "✓ Application started with PM2"

stop:
	pm2 stop all
	@echo "✓ Application stopped"

logs:
	pm2 logs

monit:
	pm2 monit

status:
	pm2 status

health:
	@curl -s http://localhost:3000/health | jq '.' || echo "Service not responding"

clean:
	pm2 delete all
	@echo "✓ All PM2 processes removed"

restart:
	pm2 restart all
	@echo "✓ Application restarted"

shell:
	pm2 exec ecosystem.config.js

