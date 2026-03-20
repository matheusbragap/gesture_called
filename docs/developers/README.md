# Configuração do Ambiente (Setup)

Instale e valide estes itens antes de rodar o projeto.

### Ferramentas base

#### Git

Use o Git para clonar o repositório.

* Baixe em [git-scm.com/install](https://git-scm.com/install)
* Valide com:

```bash
git --version
```

#### Flutter SDK

Use o Flutter para rodar o app.

* Siga a instalação rápida em [Flutter Quick Install](https://docs.flutter.dev/install/quick)
* Valide com:

```bash
flutter --version
flutter doctor
```

#### Node.js

Use o Node.js no backend e nos scripts do projeto.

* Baixe em [nodejs.org/pt-br/download](https://nodejs.org/pt-br/download)
* Prefira a versão **LTS**
* Valide com:

```bash
node --version
npm --version
```

### Android

Para rodar no emulador, instale o **Android Studio**.

Confirme estes componentes:

* Android SDK
* Android SDK Platform
* Android SDK Build-Tools
* Android SDK Platform-Tools
* Android SDK Command-line Tools
* Android Emulator

Aceite as licenças:

```bash
flutter doctor --android-licenses
```

Valide o ambiente:

```bash
flutter doctor
```

### Windows

Para rodar como app desktop, instale o **Visual Studio**.

Durante a instalação, marque:

* **Desktop development with C++**

Depois valide:

```bash
flutter doctor
```

Se o alvo Windows não estiver habilitado:

```bash
flutter config --enable-windows-desktop
```

{% hint style="warning" %}
Para buildar ou rodar no Windows, o pacote de C++ fica no **Visual Studio**. Ele não fica no Android Studio.
{% endhint %}

### Checklist rápido

Confirme estes comandos sem erro:

```bash
git --version
flutter --version
flutter doctor
node --version
npm --version
```
