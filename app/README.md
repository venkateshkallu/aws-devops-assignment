# AWS DevOps Demo App

A simple Node.js Express application demonstrating AWS DevOps practices with ECS, Terraform, and CI/CD.

## Features

- **Home Page (`/`)**: Welcome page with system status
- **Health Check (`/health`)**: Detailed system health information
- Responsive design for mobile and desktop
- Real-time server information display
- Docker containerization ready

## Quick Start

### Local Development

```bash
# Install dependencies
npm install

# Start the application
npm start

# Development mode with auto-reload
npm run dev
```

The app will be available at:
- Home: http://localhost:3000
- Health: http://localhost:3000/health

### Docker

```bash
# Build the image
docker build -t aws-devops-demo .

# Run the container
docker run -p 3000:3000 aws-devops-demo
```

## Project Structure

```
app/
├── server.js          # Main application server
├── package.json       # Dependencies and scripts
├── Dockerfile         # Container configuration
├── public/
│   └── styles.css     # Application styles
└── views/
    ├── index.ejs      # Home page template
    └── health.ejs     # Health check template
```

## API Endpoints

- `GET /` - Home page
- `GET /health` - Health check endpoint

## Technologies Used

- Node.js
- Express.js
- EJS templating
- CSS3 with responsive design
- Docker

## Health Check

The `/health` endpoint provides:
- System status
- Server uptime
- Memory usage
- CPU information
- Hostname and platform details