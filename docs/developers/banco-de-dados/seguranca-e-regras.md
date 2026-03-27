# Segurança e Regras

Nesta versão, a documentação de banco foca na estrutura das tabelas e nos relacionamentos.

As tabelas `profiles`, `tickets` e `messages` se integram com a autenticação do Supabase por meio de referências para `auth.users`. Isso garante que usuários e dados operacionais fiquem conectados no mesmo fluxo.

Se necessário, esta página pode ser expandida depois com políticas de acesso e regras por perfil.
