CREATE DATABASE IF NOT EXISTS CrudDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE CrudDB;

DROP TABLE IF EXISTS Produtos_Log;
DROP TABLE IF EXISTS Produtos;

CREATE TABLE Produtos (
    id            INT            NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nome          VARCHAR(100)   NOT NULL,
    categoria     VARCHAR(50)    NOT NULL,
    preco         DECIMAL(10,2)  NOT NULL CHECK (preco >= 0),
    estoque       INT            NOT NULL DEFAULT 0 CHECK (estoque >= 0),
    criado_em     DATETIME       DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Produtos_Log (
    id            INT            NOT NULL AUTO_INCREMENT PRIMARY KEY,
    produto_id    INT            NOT NULL,
    operacao      VARCHAR(10)    NOT NULL,
    campo         VARCHAR(50),
    valor_antes   TEXT,
    valor_depois  TEXT,
    usuario       VARCHAR(100)   DEFAULT (CURRENT_USER()),
    executado_em  DATETIME       DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS trg_produtos_insert;
DELIMITER $$
CREATE TRIGGER trg_produtos_insert
AFTER INSERT ON Produtos
FOR EACH ROW
BEGIN
    INSERT INTO Produtos_Log (produto_id, operacao, campo, valor_antes, valor_depois)
    VALUES (NEW.id, 'INSERT', 'nome', NULL, NEW.nome);
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS trg_produtos_delete;
DELIMITER $$
CREATE TRIGGER trg_produtos_delete
AFTER DELETE ON Produtos
FOR EACH ROW
BEGIN
    INSERT INTO Produtos_Log (produto_id, operacao, campo, valor_antes, valor_depois)
    VALUES (
        OLD.id,
        'DELETE',
        'registro_completo',
        CONCAT('nome=', OLD.nome, ' | preco=', OLD.preco, ' | estoque=', OLD.estoque),
        NULL
    );
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS trg_produtos_update;
DELIMITER $$
CREATE TRIGGER trg_produtos_update
AFTER UPDATE ON Produtos
FOR EACH ROW
BEGIN
    IF NEW.nome <> OLD.nome THEN
        INSERT INTO Produtos_Log (produto_id, operacao, campo, valor_antes, valor_depois)
        VALUES (NEW.id, 'UPDATE', 'nome', OLD.nome, NEW.nome);
    END IF;

    IF NEW.preco <> OLD.preco THEN
        INSERT INTO Produtos_Log (produto_id, operacao, campo, valor_antes, valor_depois)
        VALUES (NEW.id, 'UPDATE', 'preco', CAST(OLD.preco AS CHAR), CAST(NEW.preco AS CHAR));
    END IF;

    IF NEW.estoque <> OLD.estoque THEN
        INSERT INTO Produtos_Log (produto_id, operacao, campo, valor_antes, valor_depois)
        VALUES (NEW.id, 'UPDATE', 'estoque', CAST(OLD.estoque AS CHAR), CAST(NEW.estoque AS CHAR));
    END IF;

    IF NEW.categoria <> OLD.categoria THEN
        INSERT INTO Produtos_Log (produto_id, operacao, campo, valor_antes, valor_depois)
        VALUES (NEW.id, 'UPDATE', 'categoria', OLD.categoria, NEW.categoria);
    END IF;
END$$
DELIMITER ;

INSERT INTO Produtos (nome, categoria, preco, estoque) VALUES
('Teclado Mecânico', 'Periféricos',  349.90, 15),
('Monitor 24"',      'Monitores',   1299.00,  8),
('Mouse Gamer',      'Periféricos',  189.90, 22),
('SSD 1TB',          'Armazenamento', 449.00, 30);────

SELECT * FROM Produtos;
SELECT * FROM Produtos_Log ORDER BY executado_em DESC;
SELECT * FROM Produtos_Log WHERE operacao = 'INSERT';
SELECT * FROM Produtos_Log WHERE operacao = 'UPDATE';
SELECT * FROM Produtos_Log WHERE operacao = 'DELETE';