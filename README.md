# ConexaoBiblioteca

[versao em portugues](README-pt-br.md)

ConexaoBiblioteca is a small product management CRUD built with Node.js and Express. It serves a static frontend from `public/` and exposes a REST API for listing, creating, updating, deleting, and auditing products.

## Overview

- Product CRUD with a browser-based interface
- REST API for products and audit logs
- Static frontend served directly by Express
- CORS enabled for local development

## Stack

- Node.js
- Express
- MySQL via `mysql2/promise`
- Plain HTML/CSS/JavaScript frontend

## Project Structure

- `server.js` - Express server and API routes
- `public/index.html` - Main frontend page
- `schema.sql` - Database schema and sample data reference
- `package.json` - Scripts and dependencies

## Requirements

- Node.js 18 or newer
- npm
- MySQL database access

## Setup

1. Install dependencies:

```bash
npm install
```

2. Configure the database connection:

The current connection settings are defined directly in `server.js`. Update the host, port, database, user, and password before running the app in a local or new environment.

3. Prepare the database schema:

The repository includes `schema.sql` with the table and trigger definitions used by the app. Review it before running it in your database environment, since it may need to be adjusted to match the SQL dialect you are using.

## Run

Start the server:

```bash
npm start
```

For development with automatic restart:

```bash
npm run dev
```

By default, the application runs at:

```text
http://localhost:3000
```

## API

### Products

- `GET /api/produtos` - List all products
- `GET /api/produtos/:id` - Get one product by ID
- `POST /api/produtos` - Create a product
- `PUT /api/produtos/:id` - Update a product
- `DELETE /api/produtos/:id` - Delete a product

### Logs

- `GET /api/logs` - List the latest audit log entries

## Request Example

Use this payload for `POST /api/produtos` and `PUT /api/produtos/:id`:

```json
{
  "nome": "Mechanical Keyboard",
  "categoria": "Peripherals",
  "preco": 349.9,
  "estoque": 15
}
```

## Database Notes

- `Produtos` stores the product records
- `Produtos_Log` stores the audit history
- Triggers capture `INSERT`, `UPDATE`, and `DELETE` events

## Security

Database credentials are currently hardcoded in `server.js`. For production use, move them to environment variables or another secret-management mechanism.

## License

No license has been defined yet.
