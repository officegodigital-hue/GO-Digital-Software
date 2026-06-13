// routes/employees.js — Employee Users CRUD API
const express = require('express');
const router  = express.Router();
const bcrypt  = require('bcrypt');
const db      = require('../config/db');

const SALT_ROUNDS = 10;

// GET /api/employees
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT id, full_name, initials, staff_id, email, username,
              role, is_active, created_at
       FROM employee_users ORDER BY created_at DESC`
    );
    return res.json({ success: true, data: rows });
  } catch (err) {
    console.error('GET /employees ERROR:', err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
});

// GET /api/employees/:id
router.get('/:id', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT id, first_name, middle_name, last_name, full_name, initials,
              staff_id, email, username, role, is_active, created_at
       FROM employee_users WHERE id = ?`,
      [req.params.id]
    );
    if (rows.length === 0)
      return res.status(404).json({ success: false, message: 'Employee not found' });
    return res.json({ success: true, data: rows[0] });
  } catch (err) {
    console.error('GET /employees/:id ERROR:', err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/employees — Create
router.post('/', async (req, res) => {
  const { firstName, middleName = '', lastName, staffId, email, username, password, role } = req.body;

  if (!firstName || !lastName || !staffId || !email || !username || !password || !role)
    return res.status(400).json({ success: false, message: 'All fields are required' });

  const fullName = `${firstName} ${middleName}`.trim();
  const initials = (firstName[0] + (lastName[0] || '')).toUpperCase();

  try {
    const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);
    const [result] = await db.query(
      `INSERT INTO employee_users
         (first_name, middle_name, last_name, full_name, initials,
          staff_id, email, username, password, role, is_active)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)`,
      [firstName, middleName, lastName, fullName, initials,
       staffId, email, username, hashedPassword, role]
    );
    return res.status(201).json({
      success: true,
      message: 'Employee created',
      data: {
        id: result.insertId, full_name: fullName, initials,
        staff_id: staffId, email, username, role, is_active: 1,
      },
    });
  } catch (err) {
    console.error('POST /employees ERROR:', err.message);
    if (err.code === 'ER_DUP_ENTRY')
      return res.status(409).json({ success: false, message: 'Staff ID, email or username already exists' });
    return res.status(500).json({ success: false, message: err.message });
  }
});

// PUT /api/employees/:id — Full Update (Edit)
// Body: { firstName, middleName, lastName, staffId, email, username, role, password? }
router.put('/:id', async (req, res) => {
  const { firstName, middleName = '', lastName, staffId, email, username, role, password } = req.body;

  if (!firstName || !lastName || !staffId || !email || !username || !role)
    return res.status(400).json({ success: false, message: 'All fields except password are required' });

  const fullName = `${firstName} ${middleName}`.trim();
  const initials = (firstName[0] + (lastName[0] || '')).toUpperCase();

  try {
    // Check duplicate for other records (not this one)
    const [existing] = await db.query(
      `SELECT id FROM employee_users
       WHERE (staff_id = ? OR email = ? OR username = ?) AND id != ?`,
      [staffId, email, username, req.params.id]
    );
    if (existing.length > 0)
      return res.status(409).json({
        success: false,
        message: 'Staff ID, email or username already used by another employee',
      });

    // If password provided, hash it and update; otherwise keep existing
    if (password && password.trim() !== '') {
      const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);
      await db.query(
        `UPDATE employee_users SET
           first_name=?, middle_name=?, last_name=?, full_name=?, initials=?,
           staff_id=?, email=?, username=?, password=?, role=?
         WHERE id=?`,
        [firstName, middleName, lastName, fullName, initials,
         staffId, email, username, hashedPassword, role, req.params.id]
      );
    } else {
      // Update without changing password
      await db.query(
        `UPDATE employee_users SET
           first_name=?, middle_name=?, last_name=?, full_name=?, initials=?,
           staff_id=?, email=?, username=?, role=?
         WHERE id=?`,
        [firstName, middleName, lastName, fullName, initials,
         staffId, email, username, role, req.params.id]
      );
    }

    return res.json({
      success: true,
      message: 'Employee updated successfully',
      data: { id: parseInt(req.params.id), full_name: fullName, initials, staff_id: staffId, email, username, role },
    });
  } catch (err) {
    console.error('PUT /employees/:id ERROR:', err.message);
    if (err.code === 'ER_DUP_ENTRY')
      return res.status(409).json({ success: false, message: 'Staff ID, email or username already exists' });
    return res.status(500).json({ success: false, message: err.message });
  }
});

// PATCH /api/employees/:id — Toggle status / update role only
router.patch('/:id', async (req, res) => {
  const { role, isActive } = req.body;
  const updates = [];
  const values  = [];
  if (role     !== undefined) { updates.push('role = ?');      values.push(role); }
  if (isActive !== undefined) { updates.push('is_active = ?'); values.push(isActive ? 1 : 0); }
  if (updates.length === 0)
    return res.status(400).json({ success: false, message: 'Nothing to update' });
  values.push(req.params.id);
  try {
    const [result] = await db.query(
      `UPDATE employee_users SET ${updates.join(', ')} WHERE id = ?`, values
    );
    if (result.affectedRows === 0)
      return res.status(404).json({ success: false, message: 'Employee not found' });
    return res.json({ success: true, message: 'Employee updated' });
  } catch (err) {
    console.error('PATCH /employees/:id ERROR:', err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
});

// DELETE /api/employees/:id
router.delete('/:id', async (req, res) => {
  try {
    const [result] = await db.query(
      'DELETE FROM employee_users WHERE id = ?', [req.params.id]
    );
    if (result.affectedRows === 0)
      return res.status(404).json({ success: false, message: 'Employee not found' });
    return res.json({ success: true, message: 'Employee deleted' });
  } catch (err) {
    console.error('DELETE /employees/:id ERROR:', err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;