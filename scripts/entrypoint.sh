set -e

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

# Função para instalar o Genymotion
install_genymotion() {
    if [ ! -d "/opt/genymotion" ]; then
        echo "[*] Instalando Genymotion..."
        wget https://dl.genymotion.com/genymotion-3.1.2-linux_x64.bin -O /tmp/genymotion-installer.bin
        chmod +x /tmp/genymotion-installer.bin
        /tmp/genymotion-installer.bin -y -d /opt/genymotion
        rm /tmp/genymotion-installer.bin
        echo '#!/bin/sh\ncd /opt/genymotion && ./genymotion &' > /usr/local/bin/genymotion
        chmod +x /usr/local/bin/genymotion
        echo "export GENYMOTION_HOME=/opt/genymotion" >> ~/.bashrc
        echo "alias start-genymotion='cd /opt/genymotion && ./genymotion &'" >> ~/.bashrc
    else
        echo "[*] Genymotion já está instalado em /opt/genymotion"
    fi
}

# Função para instalar o Burp Suite
install_burpsuite() {
    if [ ! -d "/opt/burpsuite" ]; then
        echo "[*] Instalando Burp Suite..."
        wget "https://portswigger.net/burp/releases/download?product=community&version=2023.12.1.1&type=Linux" -O /tmp/burpsuite.sh
        chmod +x /tmp/burpsuite.sh
        /tmp/burpsuite.sh -q -dir /opt/burpsuite
        rm /tmp/burpsuite.sh
        echo '#!/bin/sh\njava -jar /opt/burpsuite/BurpSuiteCommunity.jar &' > /usr/local/bin/burpsuite
        chmod +x /usr/local/bin/burpsuite
        echo "export BURP_SUITE_HOME=/opt/burpsuite" >> ~/.bashrc
        echo "alias start-burp='java -jar /opt/burpsuite/BurpSuiteCommunity.jar &'" >> ~/.bashrc
    else
        echo "[*] Burp Suite já está instalado em /opt/burpsuite"
    fi
}

# Função para instalar o Tor Browser
install_tor() {
    if [ ! -d "/opt/tor-browser" ]; then
        echo "[*] Instalando Tor Browser..."
        curl -fsSL https://www.torproject.org/dist/torbrowser/10.0.17/tor-browser-linux64-10.0.17_en-US.tar.xz -o /tmp/tor-browser.tar.xz
        tar -xvf /tmp/tor-browser.tar.xz -C /opt
        mv /opt/tor-browser_en-US /opt/tor-browser
        rm /tmp/tor-browser.tar.xz
        echo "alias start-tor='/opt/tor-browser/start-tor-browser &'" >> ~/.bashrc
    else
        echo "[*] Tor Browser já está instalado em /opt/tor-browser"
    fi
}

# Função para instalar o APKTool
install_apktool() {
    if [ ! -f "/opt/apktool.jar" ]; then
        echo "[*] Instalando APKTool..."
        wget https://github.com/iBotPeaches/Apktool/releases/download/v2.5.0/apktool_2.5.0.jar -O /opt/apktool.jar
        echo '#!/bin/sh\njava -jar /opt/apktool.jar "$@"' > /usr/local/bin/apktool
        chmod +x /usr/local/bin/apktool
        echo "export APKTOOL_PATH=/opt/apktool.jar" >> ~/.bashrc
    else
        echo "[*] APKTool já está instalado em /opt/apktool.jar"
    fi
}

# Função para instalar o JADX
install_jadx() {
    if [ ! -d "/opt/jadx" ]; then
        echo "[*] Instalando JADX..."
        wget https://github.com/skylot/jadx/releases/download/v1.3.0/jadx-1.3.0.zip -O /tmp/jadx.zip
        unzip /tmp/jadx.zip -d /opt/jadx
        rm /tmp/jadx.zip
        ln -sf /opt/jadx/bin/jadx /usr/local/bin/jadx
        ln -sf /opt/jadx/bin/jadx-gui /usr/local/bin/jadx-gui
        echo "alias start-jadx='jadx-gui &'" >> ~/.bashrc
    else
        echo "[*] JADX já está instalado em /opt/jadx"
    fi
}

# Função para instalar o Frida
install_frida() {
    if ! command_exists frida; then
        echo "[*] Instalando Frida e ferramentas Python..."
        pip3 install frida-tools pyaes reflutter
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    else
        echo "[*] Frida já está instalado"
    fi
}

# Função para instalar o Baksmali
install_baksmali() {
    if [ ! -f "/tools/baksmali.jar" ]; then
        echo "[*] Instalando Baksmali..."
        mkdir -p /tools
        wget https://bitbucket.org/JesusFreke/smali/downloads/baksmali-2.5.2.jar -O /tools/baksmali.jar
        echo '#!/bin/sh\njava -jar /tools/baksmali.jar "$@"' > /usr/local/bin/baksmali
        chmod +x /usr/local/bin/baksmali
        echo "export BAKSMALI_PATH=/tools/baksmali.jar" >> ~/.bashrc
    else
        echo "[*] Baksmali já está instalado em /tools/baksmali.jar"
    fi
}

# Função para instalar o APK Signer
install_apksigner() {
    if [ ! -f "/app/apk-signers/uber-apk-signer/uber-apk-signer.jar" ]; then
        echo "[*] Instalando Uber APK Signer..."
        mkdir -p /app/apk-signers/uber-apk-signer
        curl -L -o /app/apk-signers/uber-apk-signer/uber-apk-signer.jar \
          https://github.com/patrickfav/uber-apk-signer/releases/download/v1.3.0/uber-apk-signer-1.3.0.jar
        echo '#!/bin/sh\njava -jar /app/apk-signers/uber-apk-signer/uber-apk-signer.jar "$@"' > /usr/local/bin/uber-apk-signer
        chmod +x /usr/local/bin/uber-apk-signer

        echo "[*] Criando keystore padrão..."
        mkdir -p /app/apk-signers/keys
        keytool -genkey -v -keystore /app/apk-signers/keys/keystore.jks \
          -keyalg RSA -keysize 2048 -validity 10000 \
          -alias androiddebugkey \
          -storepass android -keypass android \
          -dname "CN=Android Debug,O=Android,C=US"

        echo "export UBER_SIGNER_PATH=/app/apk-signers/uber-apk-signer/uber-apk-signer.jar" >> ~/.bashrc
        echo "export KEYSTORE_PATH=/app/apk-signers/keys/keystore.jks" >> ~/.bashrc
        echo "export KEYSTORE_PASS=android" >> ~/.bashrc
        echo "export KEY_ALIAS=androiddebugkey" >> ~/.bashrc
        echo "export KEY_PASS=android" >> ~/.bashrc
    else
        echo "[*] Uber APK Signer já está instalado"
    fi
}

# Processa argumentos
if [ $# -eq 0 ]; then
    echo "Nenhum argumento fornecido. Instalando todas as ferramentas..."
    install_genymotion
    install_burpsuite
    install_tor
    install_apktool
    install_jadx
    install_frida
    install_baksmali
    install_apksigner
else
    for arg in "$@"; do
        case $arg in
            --install-genymotion) install_genymotion ;;
            --install-burpsuite) install_burpsuite ;;
            --install-tor) install_tor ;;
            --install-apktool) install_apktool ;;
            --install-jadx) install_jadx ;;
            --install-frida) install_frida ;;
            --install-baksmali) install_baksmali ;;
            --install-apksigner) install_apksigner ;;
            --install-all)
                install_genymotion
                install_burpsuite
                install_tor
                install_apktool
                install_jadx
                install_frida
                install_baksmali
                install_apksigner
                ;;
            *)
                echo "[!] Argumento não reconhecido: $arg"
                echo "Argumentos válidos:"
                echo "--install-genymotion --install-burpsuite --install-tor"
                echo "--install-apktool --install-jadx --install-frida"
                echo "--install-baksmali --install-apksigner --install-all"
                ;;
        esac
    done
fi

exec bash --login