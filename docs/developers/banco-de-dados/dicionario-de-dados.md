---
description: Estrutura de tabelas, campos, tipos e relacionamentos do banco.
---

# Dicionário de Dados

Esta página centraliza a estrutura das tabelas do banco.

### `categories`

Finalidade: armazenar as categorias disponíveis para classificação dos chamados.

| Coluna        | Tipo                       | Chave | Obrigatório | Descrição                         |
| ------------- | -------------------------- | ----- | ----------- | --------------------------------- |
| `id`          | `bigint`                   | PK    | Sim         | Identificador único da categoria. |
| `name`        | `text`                     | -     | Sim         | Nome da categoria.                |
| `description` | `text`                     | -     | Não         | Descrição da categoria.           |
| `isActive`    | `boolean`                  | -     | Sim         | Indica se a categoria está ativa. |
| `created_at`  | `timestamp with time zone` | -     | Sim         | Data de criação do registro.      |

### `companies`

Finalidade: armazenar as empresas cadastradas no sistema.

| Coluna        | Tipo                       | Chave | Obrigatório | Descrição                       |
| ------------- | -------------------------- | ----- | ----------- | ------------------------------- |
| `id`          | `bigint`                   | PK    | Sim         | Identificador único da empresa. |
| `name`        | `text`                     | -     | Sim         | Nome da empresa.                |
| `description` | `text`                     | -     | Não         | Descrição da empresa.           |
| `isActive`    | `boolean`                  | -     | Sim         | Indica se a empresa está ativa. |
| `created_at`  | `timestamp with time zone` | -     | Sim         | Data de criação do registro.    |

### `departments`

Finalidade: armazenar os departamentos vinculados a uma empresa.

| Coluna        | Tipo                       | Chave | Obrigatório | Descrição                                     |
| ------------- | -------------------------- | ----- | ----------- | --------------------------------------------- |
| `id`          | `bigint`                   | PK    | Sim         | Identificador único do departamento.          |
| `name`        | `text`                     | -     | Sim         | Nome do departamento.                         |
| `description` | `text`                     | -     | Não         | Descrição do departamento.                    |
| `company_id`  | `bigint`                   | FK    | Sim         | Empresa à qual o departamento pertence.       |
| `location`    | `text`                     | -     | Não         | Localização física ou lógica do departamento. |
| `isActive`    | `boolean`                  | -     | Sim         | Indica se o departamento está ativo.          |
| `created_at`  | `timestamp with time zone` | -     | Sim         | Data de criação do registro.                  |

Relacionamento:

* `company_id` → `companies.id`

### `profiles`

Finalidade: armazenar os dados complementares dos usuários autenticados.

| Coluna         | Tipo                       | Chave  | Obrigatório | Descrição                                                    |
| -------------- | -------------------------- | ------ | ----------- | ------------------------------------------------------------ |
| `id`           | `uuid`                     | PK, FK | Sim         | Identificador do usuário. Também referencia `auth.users.id`. |
| `name`         | `text`                     | -      | Sim         | Nome do usuário.                                             |
| `email`        | `character varying`        | -      | Sim         | E-mail do usuário.                                           |
| `phone_number` | `text`                     | -      | Não         | Telefone do usuário.                                         |
| `company_id`   | `bigint`                   | FK     | Não         | Empresa associada ao usuário.                                |
| `isActive`     | `boolean`                  | -      | Sim         | Indica se o usuário está ativo.                              |
| `lastSeen`     | `timestamp with time zone` | -      | Sim         | Último acesso registrado.                                    |
| `created_at`   | `timestamp with time zone` | -      | Sim         | Data de criação do perfil.                                   |

Relacionamentos:

* `id` → `auth.users.id`
* `company_id` → `companies.id`

### `tickets`

Finalidade: armazenar os chamados abertos no sistema.

| Coluna                 | Tipo                       | Chave | Obrigatório | Descrição                                       |
| ---------------------- | -------------------------- | ----- | ----------- | ----------------------------------------------- |
| `id`                   | `bigint`                   | PK    | Sim         | Identificador único do chamado.                 |
| `title`                | `text`                     | -     | Sim         | Título do chamado.                              |
| `description`          | `text`                     | -     | Não         | Descrição detalhada do problema ou solicitação. |
| `creator_employee_id`  | `uuid`                     | FK    | Sim         | Usuário que abriu o chamado.                    |
| `current_attendant_id` | `uuid`                     | FK    | Não         | Atendente responsável no momento.               |
| `department_id`        | `bigint`                   | FK    | Sim         | Departamento responsável pelo chamado.          |
| `category_id`          | `bigint`                   | FK    | Sim         | Categoria do chamado.                           |
| `status`               | `text`                     | -     | Sim         | Status atual do chamado. Valor padrão: `open`.  |
| `created_at`           | `timestamp with time zone` | -     | Sim         | Data de criação do chamado.                     |

Relacionamentos:

* `creator_employee_id` → `auth.users.id`
* `current_attendant_id` → `auth.users.id`
* `department_id` → `departments.id`
* `category_id` → `categories.id`

### `messages`

Finalidade: armazenar as mensagens trocadas dentro de cada chamado.

| Coluna           | Tipo                       | Chave | Obrigatório | Descrição                            |
| ---------------- | -------------------------- | ----- | ----------- | ------------------------------------ |
| `id`             | `bigint`                   | PK    | Sim         | Identificador único da mensagem.     |
| `content`        | `text`                     | -     | Sim         | Conteúdo textual da mensagem.        |
| `attachment_url` | `text`                     | -     | Não         | URL do anexo enviado na mensagem.    |
| `ticket_id`      | `bigint`                   | FK    | Não         | Chamado ao qual a mensagem pertence. |
| `sender_id`      | `uuid`                     | FK    | Não         | Usuário remetente da mensagem.       |
| `created_at`     | `timestamp with time zone` | -     | Sim         | Data de criação da mensagem.         |

Relacionamentos:

* `ticket_id` → `tickets.id`
* `sender_id` → `auth.users.id`

### Resumo das dependências

* `companies` é a base para `departments` e `profiles`
* `departments` depende de `companies`
* `profiles` depende de `auth.users` e pode depender de `companies`
* `tickets` depende de `auth.users`, `departments` e `categories`
* `messages` depende de `tickets` e `auth.users`
