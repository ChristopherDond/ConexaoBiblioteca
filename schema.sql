USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'CrudDB')
    CREATE DATABASE CrudDB;
GO

USE CrudDB;
GO

IF OBJECT_ID('Produtos_Log', 'U') IS NOT NULL DROP TABLE Produtos_Log;
IF OBJECT_ID('Produtos', 'U') IS NOT NULL DROP TABLE Produtos;

CREATE TABLE Produtos (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    nome        VARCHAR(100)   NOT NULL,
    categoria   VARCHAR(50)    NOT NULL,
    preco       DECIMAL(10,2)  NOT NULL CHECK (preco >= 0),
    estoque     INT            NOT NULL DEFAULT 0 CHECK (estoque >= 0),
    criado_em   DATETIME       DEFAULT GETDATE(),
    atualizado_em DATETIME     DEFAULT GETDATE()
);

CREATE TABLE Produtos_Log (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    produto_id  INT            NOT NULL,
    operacao    VARCHAR(10)    NOT NULL,
    campo       VARCHAR(50),
    valor_antes NVARCHAR(255),
    valor_depois NVARCHAR(255),
    usuario     VARCHAR(100)   DEFAULT SYSTEM_USER,
    executado_em DATETIME      DEFAULT GETDATE()
);
GO

CREATE OR ALTER TRIGGER trg_produtos_insert
ON Produtos
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Produtos_Log (produto_id, operacao, campo, valor_antes, valor_depois)
    SELECT
        i.id,
        'INSERT',
        'nome',
        NULL,
        i.nome
    FROM inserted i;
END;
GO

CREATE OR ALTER TRIGGER trg_produtos_delete
ON Produtos
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Produtos_Log (produto_id, operacao, campo, valor_antes, valor_depois)
    SELECT
        d.id,
        'DELETE',
        'registro_completo',
        CONCAT('nome=', d.nome, ' | preco=', d.preco, ' | estoque=', d.estoque),
        NULL
    FROM deleted d;
END;
GO

CREATE OR ALTER TRIGGER trg_produtos_update
ON Produtos
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Produtos_Log (produto_id, operacao, campo, valor_antes, valor_depois)
    SELECT i.id, 'UPDATE', 'nome', d.nome, i.nome
    FROM inserted i JOIN deleted d ON i.id = d.id
    WHERE i.nome <> d.nome;

    INSERT INTO Produtos_Log (produto_id, operacao, campo, valor_antes, valor_depois)
    SELECT i.id, 'UPDATE', 'preco', CAST(d.preco AS NVARCHAR), CAST(i.preco AS NVARCHAR)
    FROM inserted i JOIN deleted d ON i.id = d.id
    WHERE i.preco <> d.preco;

    INSERT INTO Produtos_Log (produto_id, operacao, campo, valor_antes, valor_depois)
    SELECT i.id, 'UPDATE', 'estoque', CAST(d.estoque AS NVARCHAR), CAST(i.estoque AS NVARCHAR)
    FROM inserted i JOIN deleted d ON i.id = d.id
    WHERE i.estoque <> d.estoque;

    INSERT INTO Produtos_Log (produto_id, operacao, campo, valor_antes, valor_depois)
    SELECT i.id, 'UPDATE', 'categoria', d.categoria, i.categoria
    FROM inserted i JOIN deleted d ON i.id = d.id
    WHERE i.categoria <> d.categoria;

    UPDATE Produtos
    SET atualizado_em = GETDATE()
    FROM Produtos p JOIN inserted i ON p.id = i.id;
END;
GO

INSERT INTO Produtos (nome, categoria, preco, estoque) VALUES
('Teclado Mecânico', 'Periféricos', 349.90, 15),
('Monitor 24"', 'Monitores', 1299.00, 8),
('Mouse Gamer', 'Periféricos', 189.90, 22),
('SSD 1TB', 'Armazenamento', 449.00, 30);
GO

-- Todos os produtos
SELECT * FROM Produtos;

-- Audit log completo (gerado pelos triggers)
SELECT * FROM Produtos_Log ORDER BY executado_em DESC;

-- Log só de INSERTs
SELECT * FROM Produtos_Log WHERE operacao = 'INSERT';

-- Log só de UPDATEs
SELECT * FROM Produtos_Log WHERE operacao = 'UPDATE';

-- Log só de DELETEs
SELECT * FROM Produtos_Log WHERE operacao = 'DELETE';
