# Modelagem e Relacionamentos

<figure><img src="../.gitbook/assets/supabase-schema-saeyicktujflytueaiyb.svg" alt="" width="563"><figcaption></figcaption></figure>

### Visão geral

O banco foi modelado em torno do fluxo de chamados. A tabela `companies` representa a empresa. A tabela `departments` pertence a uma empresa. A tabela `profiles` guarda os dados complementares dos usuários autenticados e pode ser vinculada a uma empresa. A tabela `tickets` concentra os chamados e se relaciona com o usuário que abriu o chamado, com o atendente atual, com o departamento responsável e com a categoria do atendimento. A tabela `messages` registra a conversa de cada chamado, ligando cada mensagem ao ticket e ao usuário remetente.

### Relacionamentos principais

* `departments.company_id` → `companies.id`
* `profiles.company_id` → `companies.id`
* `tickets.department_id` → `departments.id`
* `tickets.category_id` → `categories.id`
* `tickets.creator_employee_id` → `auth.users.id`
* `tickets.current_attendant_id` → `auth.users.id`
* `messages.ticket_id` → `tickets.id`
* `messages.sender_id` → `auth.users.id`
* `profiles.id` → `auth.users.id`

{% hint style="info" %}
As tabelas `profiles`, `tickets` e `messages` dependem da autenticação do Supabase, pois parte dos relacionamentos aponta para `auth.users`.
{% endhint %}
