const express = require('express');
const mysql   = require('mysql2/promise');
const cors    = require('cors');
const path    = require('path');

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

const pool = mysql.createPool({
  host:               '137.131.242.237',
  port:               3306,
  database:           'CrudDB',
  user:               'crud_user',
  password:           'Senac2026@',
  waitForConnections: true,
  connectionLimit:    10,
  charset:            'utf8mb4',
});

app.get('/api/produtos', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT id, nome, categoria, preco, estoque, criado_em, atualizado_em
      FROM Produtos ORDER BY id DESC
    `);
    res.json(rows);
  } catch (err) { res.status(500).json({ erro: err.message }); }
});

app.get('/api/produtos/:id', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM Produtos WHERE id = ?', [req.params.id]);
    if (!rows.length) return res.status(404).json({ erro: 'Não encontrado' });
    res.json(rows[0]);
  } catch (err) { res.status(500).json({ erro: err.message }); }
});

app.post('/api/produtos', async (req, res) => {
  const { nome, categoria, preco, estoque } = req.body;
  if (!nome || !categoria || preco == null || estoque == null)
    return res.status(400).json({ erro: 'Campos obrigatórios: nome, categoria, preco, estoque' });
  try {
    const [result] = await pool.query(
      'INSERT INTO Produtos (nome, categoria, preco, estoque) VALUES (?, ?, ?, ?)',
      [nome, categoria, preco, estoque]
    );
    const [rows] = await pool.query('SELECT * FROM Produtos WHERE id = ?', [result.insertId]);
    res.status(201).json(rows[0]);
  } catch (err) { res.status(500).json({ erro: err.message }); }
});

app.put('/api/produtos/:id', async (req, res) => {
  const { nome, categoria, preco, estoque } = req.body;
  if (!nome || !categoria || preco == null || estoque == null)
    return res.status(400).json({ erro: 'Campos obrigatórios: nome, categoria, preco, estoque' });
  try {
    const [result] = await pool.query(
      'UPDATE Produtos SET nome = ?, categoria = ?, preco = ?, estoque = ? WHERE id = ?',
      [nome, categoria, preco, estoque, req.params.id]
    );
    if (result.affectedRows === 0) return res.status(404).json({ erro: 'Não encontrado' });
    const [rows] = await pool.query('SELECT * FROM Produtos WHERE id = ?', [req.params.id]);
    res.json(rows[0]);
  } catch (err) { res.status(500).json({ erro: err.message }); }
});

app.delete('/api/produtos/:id', async (req, res) => {
  try {
    const [result] = await pool.query('DELETE FROM Produtos WHERE id = ?', [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ erro: 'Não encontrado' });
    res.json({ deletado: parseInt(req.params.id) });
  } catch (err) { res.status(500).json({ erro: err.message }); }
});

app.get('/api/logs', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT l.id, l.produto_id, l.operacao, l.campo,
             l.valor_antes, l.valor_depois, l.usuario, l.executado_em,
             p.nome AS produto_nome
      FROM Produtos_Log l
      LEFT JOIN Produtos p ON l.produto_id = p.id
      ORDER BY l.executado_em DESC
      LIMIT 100
    `);
    res.json(rows);
  } catch (err) { res.status(500).json({ erro: err.message }); }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Servidor rodando em http://localhost:${PORT}`));