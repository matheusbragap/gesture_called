# Guide Start

## Como pegar o projeto

Use este fluxo para preparar o ambiente e baixar o código.

Este projeto é um **monorepo**.

Ele reúne o app em **Flutter** e o backend em **Node.js**.

{% stepper %}
{% step %}
### Instale o Git

O Git é necessário para clonar o repositório.

* Baixe em [git-scm.com/install](https://git-scm.com/install)
* Instale a versão do seu sistema operacional
* Depois confirme a instalação:

```bash
git --version
```

Se o comando retornar uma versão, o Git está pronto.
{% endstep %}

{% step %}
### Instale o Flutter

O aplicativo do projeto usa Flutter.

* Baixe em [flutter.dev](https://docs.flutter.dev/get-started/install)
* Instale a versão do seu sistema operacional
* Depois confirme a instalação:

```bash
flutter --version
```

Se o comando retornar uma versão, o Flutter está pronto.
{% endstep %}

{% step %}
### Instale o Node.js

O backend do projeto usa Node.js.

* Baixe em [nodejs.org/pt-br/download](https://nodejs.org/pt-br/download)
* Prefira a versão **LTS**
* Depois confirme a instalação:

```bash
node --version
npm --version
```

Se os dois comandos retornarem uma versão, o ambiente está pronto.
{% endstep %}

{% step %}
### Clone o repositório

Abra o terminal, vá para o caminho de sua preferência, e rode:

```bash
git clone https://github.com/matheusbragap/gesture_called.git
```

Isso cria uma pasta chamada `gesture_called` com o projeto.
{% endstep %}

{% step %}
### Entre na pasta do projeto

No terminal, acesse a pasta clonada:

```bash
cd gesture_called
```
{% endstep %}

{% step %}
### Instale as dependências

Com a pasta do projeto aberta, rode:

```bash
npm install
```

Esse comando baixa as dependências do backend.

{% hint style="info" %}
Como este projeto é um monorepo, o app Flutter e o backend podem ter fluxos separados de instalação.
{% endhint %}
{% endstep %}
{% endstepper %}

### Fluxo completo

Se quiser fazer tudo em sequência:

```bash
git clone https://github.com/matheusbragap/gesture_called.git
cd gesture_called
npm install
```

### Verificações rápidas

Antes de começar, confirme estes itens:

* `git --version`
* `flutter --version`
* `node --version`
* `npm --version`

### Se algo falhar

{% hint style="warning" %}
Se `git` não funcionar, reinstale o Git e feche o terminal antes de abrir novamente.
{% endhint %}

{% hint style="warning" %}
Se `node` ou `npm` não funcionar, reinstale o Node.js e abra um novo terminal.
{% endhint %}

{% hint style="info" %}
O próximo passo natural é documentar como rodar o app Flutter e o backend localmente.
{% endhint %}
