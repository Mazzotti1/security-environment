# 🛡️ Android Security Toolkit Container

![Docker](https://img.shields.io/badge/Docker-Container-blue)
![Android Security](https://img.shields.io/badge/Android-Security-brightgreen)

Um container Docker com as ferramentas que eu uso para análise de segurança de aplicativos Android, incluindo ferramentas para engenharia reversa, manipulação de APKs e testes de penetração.

## 🚀 Começando

### Pré-requisitos
- Docker instalado
- 8GB+ de RAM recomendado
- KVM habilitado para Genymotion

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