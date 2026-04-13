const express = require('express');
const sql = require('mssql');
const cors = require('cors');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

const dbConfig = {
  server: 'DESKTOP-ABRUA4T',          
  database: 'CrudDB',
  user: 'sa',                    
  password: 'Lrch2848@',      
  options: {
    trustServerCertificate: true,
    enableArithAbort: true,
  },
  port: 1433,
};

// const dbConfig = {
//   server:   'maquina diferente',
//   database: 'CrudDB',
//   options: {
//     trustServerCertificate: true,
//     enableArithAbort: true,
//     trustedConnection: true,
//   },
//   port: 1433,
// };

let pool;
async function getPool() {
  if (!pool) pool = await sql.connect(dbConfig);
  return pool;
}

app.get('/api/produtos', async (req, res) => {
  try {
    const db = await getPool();
    const result = await db.request().query(`
      SELECT id, nome, categoria, preco, estoque, criado_em, atualizado_em
      FROM Produtos
      ORDER BY id DESC
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ erro: err.message });
  }
});

app.get('/api/produtos/:id', async (req, res) => {
  try {
    const db = await getPool();
    const result = await db.request()
      .input('id', sql.Int, req.params.id)
      .query('SELECT * FROM Produtos WHERE id = @id');

    if (!result.recordset.length) return res.status(404).json({ erro: 'Não encontrado' });
    res.json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ erro: err.message });
  }
});

app.post('/api/produtos', async (req, res) => {
  const { nome, categoria, preco, estoque } = req.body;
  if (!nome || !categoria || preco == null || estoque == null)
    return res.status(400).json({ erro: 'Campos obrigatórios: nome, categoria, preco, estoque' });

  try {
    const db = await getPool();
    await db.request()
      .input('nome', sql.VarChar(100), nome)
      .input('categoria', sql.VarChar(50), categoria)
      .input('preco', sql.Decimal(10, 2), preco)
      .input('estoque', sql.Int, estoque)
      .query(`INSERT INTO Produtos (nome, categoria, preco, estoque) VALUES (@nome, @categoria, @preco, @estoque)`);

    res.status(201).json({ ok: true });
  } catch (err) {
    res.status(500).json({ erro: err.message });
  }
});

app.put('/api/produtos/:id', async (req, res) => {
  const { nome, categoria, preco, estoque } = req.body;
  if (!nome || !categoria || preco == null || estoque == null)
    return res.status(400).json({ erro: 'Campos obrigatórios: nome, categoria, preco, estoque' });

  try {
    const db = await getPool();
    const result = await db.request()
      .input('id', sql.Int, req.params.id)
      .input('nome', sql.VarChar(100), nome)
      .input('categoria', sql.VarChar(50), categoria)
      .input('preco', sql.Decimal(10, 2), preco)
      .input('estoque', sql.Int, estoque)
      .query(`
      UPDATE Produtos
      SET nome = @nome, categoria = @categoria, preco = @preco, estoque = @estoque
      WHERE id = @id;
      SELECT * FROM Produtos WHERE id = @id;
    `);
if (!result.recordset.length) return res.status(404).json({ erro: 'Não encontrado' });
res.json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ erro: err.message });
  }
});

app.delete('/api/produtos/:id', async (req, res) => {
  try {
    const db = await getPool();
    const result = await db.request()
      .input('id', sql.Int, req.params.id)
      .query('DELETE FROM Produtos WHERE id = @id');

    if (result.rowsAffected[0] === 0) return res.status(404).json({ erro: 'Não encontrado' });
    res.json({ deletado: parseInt(req.params.id) });
  } catch (err) {
    res.status(500).json({ erro: err.message });
  }
});

app.get('/api/logs', async (req, res) => {
  try {
    const db = await getPool();
    const result = await db.request().query(`
      SELECT TOP 100
        l.id, l.produto_id, l.operacao, l.campo,
        l.valor_antes, l.valor_depois, l.usuario, l.executado_em,
        p.nome AS produto_nome
      FROM Produtos_Log l
      LEFT JOIN Produtos p ON l.produto_id = p.id
      ORDER BY l.executado_em DESC
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ erro: err.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor rodando em http://localhost:${PORT}`);
  console.log('Configurações do banco:', { server: dbConfig.server, database: dbConfig.database });
});
