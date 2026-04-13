# ConexaoBiblioteca

[(english version)](README.md)

Um CRUD simples de gerenciamento de produtos, construido com Node.js, Express e Microsoft SQL Server. A aplicacao serve um frontend estatico a partir de `public/` e expoe uma API REST para gerenciar produtos e consultar logs de auditoria.

## Funcionalidades

- Criar, listar, atualizar e remover produtos
- Persistencia em SQL Server com o driver `mssql`
- Log de auditoria gerado por gatilhos (triggers) no banco
- Frontend estatico servido pelo Express
- CORS habilitado para desenvolvimento local

## Estrutura do Projeto

- `server.js` - Servidor Express e rotas da API
- `public/index.html` - Interface frontend
- `schema.sql` - Schema do banco, triggers e dados de exemplo
- `package.json` - Scripts e dependencias do projeto

## Pre-requisitos

- Node.js 18+ (recomendado)
- Microsoft SQL Server
- npm

## Configuracao

1. Instale as dependencias:

```bash
npm install
```

2. Crie o banco e as tabelas:

Execute `schema.sql` no SQL Server Management Studio, Azure Data Studio ou outro cliente SQL conectado a sua instancia SQL Server.

3. Atualize a conexao com o banco em `server.js`:

A configuracao atual esta em `dbConfig` dentro de `server.js`. Substitua pelos seus dados de host, banco, usuario e senha antes de iniciar a aplicacao.

## Executando a Aplicacao

Inicie o servidor em modo de producao:

```bash
npm start
```

Ou rode com reinicio automatico durante o desenvolvimento:

```bash
npm run dev
```

Por padrao, o servidor executa em:

```text
http://localhost:3000
```

## Endpoints da API

### Produtos

- `GET /api/produtos` - Lista todos os produtos
- `GET /api/produtos/:id` - Busca um produto por ID
- `POST /api/produtos` - Cria um novo produto
- `PUT /api/produtos/:id` - Atualiza um produto existente
- `DELETE /api/produtos/:id` - Remove um produto

### Logs

- `GET /api/logs` - Lista os registros de auditoria mais recentes

## Exemplo de Corpo da Requisicao

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

O arquivo `schema.sql` cria:

- Tabela `Produtos` para os dados de produtos
- Tabela `Produtos_Log` para historico de auditoria
- Triggers para `INSERT`, `UPDATE` e `DELETE`

O schema tambem insere registros de exemplo para facilitar os testes.

## Nota de Seguranca

As credenciais do banco estao hardcoded em `server.js`. Em producao, mova essas credenciais para variaveis de ambiente antes de publicar ou compartilhar o projeto.

## Licenca

Ainda nao foi definida uma licenca para este projeto.
