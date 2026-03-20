---
description: Estruture aqui o fluxo de autenticação, autorização e uso de tokens.
---

# Autenticação e Segurança (JWT)

Centralize nesta página:

* emissão e validação de JWT
* expiração e refresh token
* headers obrigatórios
* roles, claims e permissões
* respostas de erro de autenticação

### Header padrão

```http
Authorization: Bearer <token>
```

### O que detalhar

* como obter o token
* onde ele é exigido
* tempo de expiração
* comportamento em token inválido ou expirado
* boas práticas de armazenamento no cliente
