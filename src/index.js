const express = require('express');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 3000;

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', database: 'connected' });
  } catch (error) {
    res.status(500).json({ status: 'error', database: 'disconnected', message: error.message });
  }
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ message: 'DevOps Task API', version: '1.0.2' });
});

// Start server
app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});

module.exports = app;
