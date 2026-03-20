# Guia de Instalação e Execução

Use este fluxo depois que o ambiente estiver pronto.

{% stepper %}
{% step %}
### Clone o repositório

```bash
git clone https://github.com/matheusbragap/gesture_called.git
cd gesture_called
npm install
```

Isso prepara a base do projeto.
{% endstep %}

{% step %}
### Valide o ambiente Flutter

Rode:

```bash
flutter doctor
```

Corrija qualquer pendência antes de subir o app.
{% endstep %}

{% step %}
### Entre na pasta do app Flutter

Se o app Flutter não estiver na raiz, entre no diretório correto.

Exemplo:

```bash
cd caminho/do/app
```
{% endstep %}

{% step %}
### Inicie o emulador Android

Você pode abrir pelo Android Studio em **Device Manager**.

Ou iniciar pelo terminal:

```bash
flutter emulators
flutter emulators --launch <emulator-id>
flutter devices
```

Quando o emulador aparecer em `flutter devices`, ele está pronto.
{% endstep %}

{% step %}
### Rode o app no Android

Com o emulador aberto:

```bash
flutter run
```

Se houver mais de um dispositivo:

```bash
flutter run -d <device-id>
```
{% endstep %}

{% step %}
### Rode o app no Windows

Liste os dispositivos disponíveis:

```bash
flutter devices
```

Depois rode:

```bash
flutter run -d windows
```
{% endstep %}

{% step %}
### Gere builds

Android:

```bash
flutter build apk
flutter build appbundle
```

Windows:

```bash
flutter build windows
```
{% endstep %}
{% endstepper %}

### Comandos úteis

* `r` faz hot reload
* `R` faz hot restart
* `q` encerra a execução

{% hint style="info" %}
Se o `flutter doctor` pedir licenças do Android, rode `flutter doctor --android-licenses`.
{% endhint %}
