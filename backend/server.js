require('dotenv').config();
const express = require('express');
const cors    = require('cors');

const employeeRoutes = require('./routes/employees');
const timingRoutes   = require('./routes/timings'); 
const clientRoutes     = require('./routes/clients');        // ← NEW
const credentialRoutes = require('./routes/credentials'); 
const packageRoutes    = require('./routes/packages');   
const quotationRoutes  = require('./routes/quotations');
const invoiceRoutes    = require('./routes/invoices'); 

const app  = express();
const PORT = process.env.PORT || 3000;

// ── CORS middleware — handles ALL methods including preflight ─────────────────
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin',  '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ── Routes ────────────────────────────────────────────────────────────────────
app.use('/api/employees', employeeRoutes);
app.use('/api/timings', timingRoutes);
app.use('/api/clients', clientRoutes);
app.use('/api/credentials', credentialRoutes);
app.use('/api/packages', packageRoutes);
app.use('/api/quotations', quotationRoutes);
app.use('/api/invoices', invoiceRoutes); 


// Health check
app.get('/', (req, res) => {
  res.json({ message: 'GoDigital API is running', status: 'ok' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ success: false, message: 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`GoDigital API running at http://localhost:${PORT}`);
});