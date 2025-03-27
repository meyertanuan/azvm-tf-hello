#!/bin/bash
set -e

# Update and install dependencies
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y nodejs npm

# Create app directory
mkdir -p /opt/nodejs-app
cd /opt/nodejs-app

# Copy hello.js (you'll need to scp or use another method to transfer)
cat > hello.js << 'EOL'
const http = require('http');
const hostname = '0.0.0.0';
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/html');
  
  res.end(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>Hello World</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f5f5f5;
          }
          .container {
            text-align: center;
            padding: 2rem;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
          }
          h1 {
            color: #333;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>Hello World</h1>
          <p>This is a simple Node.js web application.</p>
        </div>
      </body>
    </html>
  `);
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});
EOL

# Create a systemd service for the Node.js app
sudo tee /etc/systemd/system/nodejs-app.service > /dev/null <<'EOL'
[Unit]
Description=Node.js Hello World App
After=network.target

[Service]
Type=simple
User=azureuser
WorkingDirectory=/opt/nodejs-app
ExecStart=/usr/bin/node /opt/nodejs-app/hello.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable nodejs-app
sudo systemctl start nodejs-app