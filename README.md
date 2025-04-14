# 🛡️ Android Security Toolkit Container

![Docker](https://img.shields.io/badge/Docker-Container-blue)
![Android Security](https://img.shields.io/badge/Android-Security-brightgreen)

Um container Docker com as ferramentas que eu uso para análise de segurança de aplicativos Android, incluindo ferramentas para engenharia reversa, manipulação de APKs e testes de penetração.

### Pré-requisitos
- Docker instalado
- 8GB+ de RAM recomendado
- KVM habilitado para Genymotion


🛠️ Scripts Personalizados
Todos os scripts estão localizados em /app/scripts/:

- sign-apk.sh - Assinar APK com keystore padrão
- unsign-apk.sh - Remover assinatura de APK
- start-proxy-chain.sh - Iniciar cadeia de proxies
- convert-cert.sh - Converter formatos de certificado

## 🔧 Comandos Disponíveis

### 🧰 Ferramentas Principais

| Comando             | Descrição                                |
|---------------------|-------------------------------------------|
| `adb`               | Android Debug Bridge                      |
| `fastboot`          | Ferramenta Fastboot                       |
| `apktool`           | Descompilar/recompilar APKs              |
| `jadx`              | Decompilador Java (CLI)                   |
| `jadx-gui`          | Decompilador Java (GUI)                   |
| `baksmali`          | Desmontar arquivos DEX                    |
| `uber-apk-signer`   | Assinar APKs                              |
| `sign-apk`          | Script para assinar APK                   |
| `unsign-apk`        | Script para remover assinatura            |
| `convert-cert`      | Converter certificados                    |

### 🖥️ Ferramentas Gráficas

| Comando        | Descrição                        |
|----------------|-----------------------------------|
| `genymotion`   | Iniciar emulador Genymotion      |
| `burpsuite`    | Iniciar Burp Suite               |
| `start-tor`    | Iniciar Tor Browser              |

## 💡 Dicas
- Para usar ferramentas gráficas, certifique-se de ter um servidor X11 em execução
- Para melhor performance com Genymotion, passe --device /dev/kvm e --privileged
- Os scripts podem ser modificados em /app/scripts/ conforme necessário

## 📦 Ferramentas Incluídas

### Engenharia Reversa
- **Apktool** (v2.5.0)
- **Jadx** (v1.3.0) - GUI e CLI
- **Baksmali** (v2.5.2)

### Segurança
- **Burp Suite Community** (2023.12.1.1)
- **Frida-tools** + **PyAES**
- **Uber APK Signer** (v1.3.0)

### Infraestrutura
- **Genymotion** (3.1.2)
- **Android SDK** (Platform-tools)
- **Proxy Chain** (Tor + Squid + Privoxy)

## Recursos Instalados

- **Java OpenJDK 11**
- **Android SDK & Platform Tools**
- **ADB & Fastboot**
- **Burp Suite Community Edition**
- **Jadx & Jadx-GUI**
- **Frida**
- **Tor Browser**
- **Proxy tools (Squid, Privoxy)**
- **x11vnc** (para acesso gráfico remoto)
- **Utilitários**: `curl`, `wget`, `git`, `python3`, `pip`, `net-tools`, `gnupg`, etc.

## 🔐 Credenciais Padrão
## Keystore:
- `Caminho:` /app/apk-signers/keys/keystore.jks
- `Senha:` android
- `Alias:` androiddebugkey

## 🌐 Portas Expostas
- `1080`: SOCKS proxy  
- `8118`: Privoxy  
- `3128`: Squid  
- `9050`: Tor

## 📄 Licença
Este projeto é para fins educacionais e de pesquisa. Verifique as licenças individuais de cada ferramenta incluída.

