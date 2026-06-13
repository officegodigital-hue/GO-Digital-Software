// routes/timings.js — Time Manager Task Timings CRUD API (v2: unique task_name)
const express = require('express');
const router  = express.Router();
const db      = require('../config/db');

// GET /api/timings — list all task timings
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT id, task_name, qty, timing FROM task_timings ORDER BY id ASC`
    );
    return res.json({ success: true, data: rows });
  } catch (err) {
    console.error('GET /timings ERROR:', err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
});

// GET /api/timings/:id — single entry
router.get('/:id', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT id, task_name, qty, timing FROM task_timings WHERE id = ?`,
      [req.params.id]
    );
    if (rows.length === 0)
      return res.status(404).json({ success: false, message: 'Entry not found' });
    return res.json({ success: true, data: rows[0] });
  } catch (err) {
    console.error('GET /timings/:id ERROR:', err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/timings — create new entry (task_name must be unique)
// Body: { taskName, qty, timing }
router.post('/', async (req, res) => {
  const { taskName, qty, timing } = req.body;

  if (!taskName || !qty || !timing)
    return res.status(400).json({ success: false, message: 'taskName, qty and timing are required' });

  try {
    const [result] = await db.query(
      `INSERT INTO task_timings (task_name, qty, timing) VALUES (?, ?, ?)`,
      [taskName, qty, timing]
    );
    return res.status(201).json({
      success: true,
      message: 'Entry created',
      data: { id: result.insertId, task_name: taskName, qty, timing },
    });
  } catch (err) {
    console.error('POST /timings ERROR:', err.message);
    if (err.code === 'ER_DUP_ENTRY')
      return res.status(409).json({ success: false, message: `"${taskName}" already exists in the task log` });
    return res.status(500).json({ success: false, message: err.message });
  }
});

// PUT /api/timings/:id — update entry (task_name must remain unique)
// Body: { taskName, qty, timing }
router.put('/:id', async (req, res) => {
  const { taskName, qty, timing } = req.body;

  if (!taskName || !qty || !timing)
    return res.status(400).json({ success: false, message: 'taskName, qty and timing are required' });

  try {
    const [result] = await db.query(
      `UPDATE task_timings SET task_name = ?, qty = ?, timing = ? WHERE id = ?`,
      [taskName, qty, timing, req.params.id]
    );
    if (result.affectedRows === 0)
      return res.status(404).json({ success: false, message: 'Entry not found' });
    return res.json({ success: true, message: 'Entry updated' });
  } catch (err) {
    console.error('PUT /timings/:id ERROR:', err.message);
    if (err.code === 'ER_DUP_ENTRY')
      return res.status(409).json({ success: false, message: `"${taskName}" already exists in the task log` });
    return res.status(500).json({ success: false, message: err.message });
  }
});

// DELETE /api/timings/:id — delete entry
router.delete('/:id', async (req, res) => {
  try {
    const [result] = await db.query(
      `DELETE FROM task_timings WHERE id = ?`,
      [req.params.id]
    );
    if (result.affectedRows === 0)
      return res.status(404).json({ success: false, message: 'Entry not found' });
    return res.json({ success: true, message: 'Entry deleted' });
  } catch (err) {
    console.error('DELETE /timings/:id ERROR:', err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;