const express = require('express');
const path = require('path');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

// Set EJS as template engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

// Routes
app.get('/', (req, res) => {
  const currentTime = new Date().toLocaleString();
  res.render('index', { currentTime });
});

app.get('/health', (req, res) => {
  const healthData = {
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    cpu: os.loadavg(),
    hostname: os.hostname(),
    platform: os.platform()
  };
  
  res.render('health', { healthData });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 AWS DevOps Demo App running on port ${PORT}`);
  console.log(`📱 Home: http://localhost:${PORT}`);
  console.log(`💚 Health: http://localhost:${PORT}/health`);
});