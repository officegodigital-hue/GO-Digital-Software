// const mysql = require('mysql2');
// require('dotenv').config();

// const pool = mysql.createPool({
//   host: process.env.DB_HOST || 'localhost',
//   user: process.env.DB_USER || 'root',
//   password: process.env.DB_PASSWORD || '',
//   database: process.env.DB_NAME || 'godigital_db',
//   waitForConnections: true,
//   connectionLimit: 10
// });

// module.exports = pool.promise();

const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host:               'localhost',
  port:               3306,
  user:               'root',
  password:           '',        // ← change to empty string (XAMPP default has NO password)
  database:           'godigital_db',
  waitForConnections: true,
  connectionLimit:    10,
  queueLimit:         0,
});

module.exports = pool;