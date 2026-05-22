module.exports = {
  apps: [
    {
      name: 'node-aws-server',
      script: './src/server.js',
      instances: 'max',
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      error_file: './logs/error.log',
      out_file: './logs/out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      autorestart: true,
      watch: false,
      ignore_watch: ['node_modules', 'logs'],
      max_memory_restart: '500M',
      min_uptime: '10s',
      max_restarts: 10,
      restart_delay: 4000
    }
  ],
  deploy: {
    production: {
      user: 'ec2-user',
      host: 'YOUR_EC2_PUBLIC_IP',
      ref: 'origin/main',
      repo: 'YOUR_GITHUB_REPO_URL',
      path: '/home/ec2-user/node-aws-server',
      'post-deploy': 'npm install && pm2 reload ecosystem.config.js --env production'
    }
  }
};
