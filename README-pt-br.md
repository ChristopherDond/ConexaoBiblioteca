# ConexaoBiblioteca

[english version](README.md)

ConexaoBiblioteca e um CRUD simples de gerenciamento de produtos construido com Node.js e Express. A aplicacao entrega um frontend estatico a partir de `public/` e expoe uma API REST para listar, criar, atualizar, remover e auditar produtos.

Este repositorio foi desenvolvido como um trabalho de apresentacao no Senac Taboao da Serra.

## Visao Geral

- CRUD de produtos com interface no navegador
- API REST para produtos e logs de auditoria
- Frontend estatico servido diretamente pelo Express
- CORS habilitado para desenvolvimento local

## Stack

- Node.js
- Express
- MySQL via `mysql2/promise`
- Frontend em HTML/CSS/JavaScript puro

## Estrutura do Projeto

- `server.js` - Servidor Express e rotas da API
- `public/index.html` - Pagina principal do frontend
- `schema.sql` - Schema do banco e dados de exemplo
- `package.json` - Scripts e dependencias do projeto

## Requisitos

- Node.js 18 ou superior
- npm
- Acesso a um banco MySQL

## Configuracao

1. Instale as dependencias:

```bash
npm install
```

2. Ajuste a conexao com o banco:

As credenciais atuais estao definidas diretamente em `server.js`. Atualize host, porta, banco, usuario e senha antes de rodar a aplicacao em outro ambiente.

3. Prepare o schema do banco:

O arquivo `schema.sql` inclui as tabelas e os triggers usados pela aplicacao. Revise o script antes de executa-lo no seu ambiente, porque ele pode precisar de ajustes para o dialeto SQL do banco que voce estiver usando.

## Execucao

Inicie o servidor:

```bash
npm start
```

Para desenvolvimento com reinicio automatico:

```bash
npm run dev
```

Por padrao, a aplicacao roda em:

```text
http://localhost:3000
```

## API

### Produtos

- `GET /api/produtos` - Lista todos os produtos
- `GET /api/produtos/:id` - Busca um produto por ID
- `POST /api/produtos` - Cria um produto
- `PUT /api/produtos/:id` - Atualiza um produto
- `DELETE /api/produtos/:id` - Remove um produto

### Logs

- `GET /api/logs` - Lista os ultimos logs de auditoria

## Exemplo de Requisicao

Use este payload para `POST /api/produtos` e `PUT /api/produtos/:id`:

```json
{
  "nome": "Mechanical Keyboard",
  "categoria": "Peripherals",
  "preco": 349.9,
  "estoque": 15
}
```

## Observacoes do Banco

- `Produtos` guarda os registros de produtos
- `Produtos_Log` guarda o historico de auditoria
- Triggers registram eventos de `INSERT`, `UPDATE` e `DELETE`

## Seguranca

As credenciais do banco estao hardcoded em `server.js`. Para producao, mova esses dados para variaveis de ambiente ou outro mecanismo de gerenciamento de segredos.

## Licenca

Nenhuma licenca foi definida ainda.
