// routes/quotations.js — Quotations CRUD API (with line items)
const express = require('express');
const router  = express.Router();
const db      = require('../config/db');

// GET /api/quotations/next-number — generates the next QT-YYYY-### number
router.get('/next-number', async (req, res) => {
  try {
    const [rows] = await db.query(`SELECT COUNT(*) AS cnt FROM quotations`);
    const nextSeq = rows[0].cnt + 89; // mirrors existing QT-2024-089 style numbering
    const year = new Date().getFullYear();
    const quotationNo = `QT-${year}-${String(nextSeq).padStart(3, '0')}`;
    return res.json({ success: true, data: { quotationNo } });
  } catch (err) {
    console.error('GET /quotations/next-number ERROR:', err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
});

// GET /api/quotations — list all quotations (without items, for table view)
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT q.id, q.quotation_no, q.client_name, q.quotation_date, q.expiry_date, q.include_gst,
              q.subtotal, q.tax, q.total_amount, q.paid_amount, q.balance_amount, q.status, q.created_at,
              (SELECT qi.description FROM quotation_items qi
                WHERE qi.quotation_id = q.id ORDER BY qi.sort_order ASC, qi.id ASC LIMIT 1) AS package_type
       FROM quotations q ORDER BY q.id DESC`
    );
    return res.json({ success: true, data: rows });
  } catch (err) {
    console.error('GET /quotations ERROR:', err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
});

// PATCH /api/quotations/:id/status — update only the status (DRAFT/SENT/ACCEPTED/EXPIRED)
router.patch('/:id/status', async (req, res) => {
  const { status } = req.body;
  const allowed = ['DRAFT', 'SENT', 'ACCEPTED', 'EXPIRED'];

  if (!status || !allowed.includes(status.toUpperCase()))
    return res.status(400).json({ success: false, message: `status must be one of ${allowed.join(', ')}` });

  try {
    const [result] = await db.query(
      `UPDATE quotations SET status = ? WHERE id = ?`,
      [status.toUpperCase(), req.params.id]
    );
    if (result.affectedRows === 0)
      return res.status(404).json({ success: false, message: 'Quotation not found' });
    return res.json({ success: true, message: 'Status updated' });
  } catch (err) {
    console.error('PATCH /quotations/:id/status ERROR:', err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
});

// GET /api/quotations/:id — single quotation with its items
router.get('/:id', async (req, res) => {
  try {
    const [qRows] = await db.query(`SELECT * FROM quotations WHERE id = ?`, [req.params.id]);
    if (qRows.length === 0)
      return res.status(404).json({ success: false, message: 'Quotation not found' });

    const [items] = await db.query(
      `SELECT id, package_id, description, qty, rate, amount, paid_amount, pending_amount, sort_order
       FROM quotation_items WHERE quotation_id = ? ORDER BY sort_order ASC, id ASC`,
      [req.params.id]
    );

    return res.json({ success: true, data: { ...qRows[0], items } });
  } catch (err) {
    console.error('GET /quotations/:id ERROR:', err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/quotations — create quotation + line items
// Body: {
//   quotationNo, clientName, quotationDate, expiryDate, includeGST,
//   subtotal, tax, totalAmount, paidAmount, balanceAmount,
//   items: [{ packageId, description, qty, rate, amount, paidAmount, pendingAmount }]
// }
router.post('/', async (req, res) => {
  const {
    quotationNo, clientName, quotationDate, expiryDate, includeGST,
    subtotal, tax, totalAmount, paidAmount, balanceAmount, items,
  } = req.body;

  if (!quotationNo || !clientName || !Array.isArray(items) || items.length === 0)
    return res.status(400).json({ success: false, message: 'quotationNo, clientName and at least one item are required' });

  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const [result] = await connection.query(
      `INSERT INTO quotations
        (quotation_no, client_name, quotation_date, expiry_date, include_gst,
         subtotal, tax, total_amount, paid_amount, balance_amount, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'DRAFT')`,
      [
        quotationNo, clientName, quotationDate || '', expiryDate || '',
        includeGST ? 1 : 0,
        subtotal || 0, tax || 0, totalAmount || 0, paidAmount || 0, balanceAmount || 0,
      ]
    );

    const quotationId = result.insertId;

    for (let i = 0; i < items.length; i++) {
      const it = items[i];
      await connection.query(
        `INSERT INTO quotation_items
          (quotation_id, package_id, description, qty, rate, amount, paid_amount, pending_amount, sort_order)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          quotationId, it.packageId || null, it.description || '',
          it.qty || 1, it.rate || 0, it.amount || 0,
          it.paidAmount || 0, it.pendingAmount || 0, i,
        ]
      );
    }

    await connection.commit();

    return res.status(201).json({
      success: true,
      message: 'Quotation created',
      data: { id: quotationId, quotationNo },
    });
  } catch (err) {
    await connection.rollback();
    console.error('POST /quotations ERROR:', err.message);
    if (err.code === 'ER_DUP_ENTRY')
      return res.status(409).json({ success: false, message: `Quotation "${quotationNo}" already exists` });
    return res.status(500).json({ success: false, message: err.message });
  } finally {
    connection.release();
  }
});

// PUT /api/quotations/:id — update quotation + replace its line items
router.put('/:id', async (req, res) => {
  const {
    clientName, quotationDate, expiryDate, includeGST,
    subtotal, tax, totalAmount, paidAmount, balanceAmount, items, status,
  } = req.body;

  if (!clientName || !Array.isArray(items) || items.length === 0)
    return res.status(400).json({ success: false, message: 'clientName and at least one item are required' });

  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const [result] = await connection.query(
      `UPDATE quotations
       SET client_name = ?, quotation_date = ?, expiry_date = ?, include_gst = ?,
           subtotal = ?, tax = ?, total_amount = ?, paid_amount = ?, balance_amount = ?,
           status = COALESCE(?, status)
       WHERE id = ?`,
      [
        clientName, quotationDate || '', expiryDate || '',
        includeGST ? 1 : 0,
        subtotal || 0, tax || 0, totalAmount || 0, paidAmount || 0, balanceAmount || 0,
        status || null,
        req.params.id,
      ]
    );

    if (result.affectedRows === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Quotation not found' });
    }

    // Replace all line items
    await connection.query(`DELETE FROM quotation_items WHERE quotation_id = ?`, [req.params.id]);

    for (let i = 0; i < items.length; i++) {
      const it = items[i];
      await connection.query(
        `INSERT INTO quotation_items
          (quotation_id, package_id, description, qty, rate, amount, paid_amount, pending_amount, sort_order)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          req.params.id, it.packageId || null, it.description || '',
          it.qty || 1, it.rate || 0, it.amount || 0,
          it.paidAmount || 0, it.pendingAmount || 0, i,
        ]
      );
    }

    await connection.commit();
    return res.json({ success: true, message: 'Quotation updated' });
  } catch (err) {
    await connection.rollback();
    console.error('PUT /quotations/:id ERROR:', err.message);
    return res.status(500).json({ success: false, message: err.message });
  } finally {
    connection.release();
  }
});

// DELETE /api/quotations/:id — delete quotation (cascades to items)
router.delete('/:id', async (req, res) => {
  try {
    const [result] = await db.query(`DELETE FROM quotations WHERE id = ?`, [req.params.id]);
    if (result.affectedRows === 0)
      return res.status(404).json({ success: false, message: 'Quotation not found' });
    return res.json({ success: true, message: 'Quotation deleted' });
  } catch (err) {
    console.error('DELETE /quotations/:id ERROR:', err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;