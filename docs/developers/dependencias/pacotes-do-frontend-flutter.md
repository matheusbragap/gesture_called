---
description: Dependências e instalação do app Flutter.
---

# Pacotes do Frontend (Flutter)

Use esta página para centralizar os pacotes do app Flutter.

### Base

O app usa **Flutter** e **Dart**.

* Siga a instalação rápida em [Flutter Quick Install](https://docs.flutter.dev/install/quick)
* Valide com:

```bash
flutter --version
flutter doctor
```

### Instalação

Na pasta do app Flutter, rode:

```bash
flutter pub get
```

Para atualizar dependências:

```bash
flutter pub upgrade
```

### Arquivos de referência

Use estes arquivos como fonte de verdade:

* `pubspec.yaml`
* `pubspec.lock`

{% hint style="info" %}
Se houver dependências nativas, valide sempre com `flutter doctor` antes de rodar o app.
{% endhint %}
