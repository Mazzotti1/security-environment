set -euo pipefail

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

install_base_dependencies() {
    echo "[*] Instalando Java 11, Python 3, unzip, wget, ufw..."
    sudo apt update
    sudo apt install -y openjdk-11-jdk python3 python3-pip unzip wget ufw git adb 
}

append_env_vars() {
    echo "[*] Configurando variáveis de ambiente..."
    cat <<EOF >> ~/.bashrc

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export ANDROID_HOME=/opt/android-sdk
export GENYMOTION_HOME=/opt/genymotion
export BURP_SUITE_HOME=/opt/burpsuite
export APKTOOL_PATH=/opt/apktool.jar
export PATH="\$JAVA_HOME/bin:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/cmdline-tools/latest/bin:\$GENYMOTION_HOME:\$BURP_SUITE_HOME:/opt/tor-browser:\$HOME/.local/bin:/usr/local/bin:\$PATH"
EOF
}


open_firewall_ports() {
    echo "[*] Abrindo portas necessárias..."
    sudo ufw allow 8080/tcp
    sudo ufw allow 8000/tcp
    sudo ufw allow 9050/tcp
    sudo ufw allow 8118/tcp
    sudo ufw allow 3128/tcp
    sudo ufw allow 5037/tcp
    sudo ufw allow 5554:5555/tcp
}

install_genymotion() {
    if [ ! -d "$HOME/genymotion" ]; then
        echo "[*] Instalando Genymotion em $HOME/genymotion..."
        wget https://dl.genymotion.com/genymotion-3.1.2-linux_x64.bin -O /tmp/genymotion-installer.bin
        chmod +x /tmp/genymotion-installer.bin
        /tmp/genymotion-installer.bin -y -d $HOME/genymotion
        rm /tmp/genymotion-installer.bin

        cat <<EOF > /usr/local/bin/genymotion
#!/bin/sh
cd $HOME/genymotion && ./genymotion &
EOF
        chmod +x /usr/local/bin/genymotion

        echo "export GENYMOTION_HOME=$HOME/genymotion" >> ~/.bashrc
        echo "alias start-genymotion='cd $HOME/genymotion && ./genymotion &'" >> ~/.bashrc
    else
        echo "[*] Genymotion já está instalado em $HOME/genymotion"
    fi
}

install_burpsuite() {
    if [ ! -d "$HOME/burpsuite" ]; then
        echo "[*] Burp Suite não encontrado, iniciando a instalação..."

        if [ ! -f "/tmp/burpsuite.sh" ]; then
            echo "[*] Baixando Burp Suite..."
            wget "https://portswigger.net/burp/releases/download?product=community&version=2023.12.1.1&type=Linux" -O /tmp/burpsuite.sh
        else
            echo "[*] Instalador do Burp Suite já encontrado, prosseguindo com a instalação..."
        fi

        chmod +x /tmp/burpsuite.sh

        /tmp/burpsuite.sh -q -dir $HOME/burpsuite

        rm /tmp/burpsuite.sh
        cat <<EOF > $HOME/bin/burpsuite
        
#!/bin/sh
java -jar $HOME/burpsuite/BurpSuiteCommunity.jar &
EOF

        chmod +x $HOME/bin/burpsuite

        if ! grep -q "$HOME/bin" ~/.bashrc; then
            echo "export PATH=\$HOME/bin:\$PATH" >> ~/.bashrc
            source ~/.bashrc
        fi

        echo "[*] Burp Suite instalado com sucesso."
    else
        echo "[*] Burp Suite já está instalado"
    fi
}

install_apktool() {
    if [ ! -f "$HOME/apktool.jar" ]; then
        echo "[*] Instalando APKTool..."
        wget https://github.com/iBotPeaches/Apktool/releases/download/v2.5.0/apktool_2.5.0.jar -O $HOME/apktool.jar

        mkdir -p $HOME/bin
        cat <<EOF > $HOME/bin/apktool
#!/bin/sh
java -jar $HOME/apktool.jar "\$@"
EOF

        chmod +x $HOME/bin/apktool

        if ! grep -q "$HOME/bin" ~/.bashrc; then
            echo "export PATH=\$HOME/bin:\$PATH" >> ~/.bashrc
            source ~/.bashrc
        fi
    else
        echo "[*] APKTool já está instalado"
    fi
}

install_jadx_gui() {
    if [ ! -d "$HOME/jadx" ]; then
        echo "[*] Instalando JADX..."
        wget https://github.com/skylot/jadx/releases/download/v1.5.1/jadx-1.5.1.zip -O /tmp/jadx.zip

        temp_dir=$(mktemp -d)
        unzip -q /tmp/jadx.zip -d "$temp_dir"

        extracted_dir=$(find "$temp_dir" -type f -path "*/bin/jadx" | head -n 1 | xargs dirname | xargs dirname)

        if [ -n "$extracted_dir" ]; then
            mv "$extracted_dir" "$HOME/jadx"
        else
            echo "[!] Diretório extraído do jadx não encontrado. Abortando."
            rm -rf "$temp_dir"
            return 1
        fi

        rm -rf /tmp/jadx.zip "$temp_dir"

        mkdir -p "$HOME/bin"
        ln -sf "$HOME/jadx/bin/jadx" "$HOME/bin/jadx"
        ln -sf "$HOME/jadx/bin/jadx-gui" "$HOME/bin/jadx-gui"

        if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc"; then
            echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
        fi

        if ! grep -q "alias start-jadx=" "$HOME/.bashrc"; then
            echo "alias start-jadx='jadx-gui &'" >> "$HOME/.bashrc"
        fi

        echo "[*] JADX instalado com sucesso! Reinicie o terminal ou execute 'source ~/.bashrc'."
    else
        echo "[*] JADX já está instalado em $HOME/jadx"
    fi
}

install_frida() {
    if ! command_exists frida; then
        echo "[*] Instalando Frida e ferramentas Python..."
        pip3 install --user frida-tools pyaes reflutter
    else
        echo "[*] Frida já está instalado"
    fi
}

install_smali_tools() {
    if [ ! -f "$HOME/baksmali.jar" ]; then
        echo "[*] Instalando smali/baksmali..."

        wget https://bitbucket.org/JesusFreke/smali/downloads/baksmali-2.5.2.jar -O "$HOME/baksmali.jar"
        wget https://bitbucket.org/JesusFreke/smali/downloads/smali-2.5.2.jar -O "$HOME/smali.jar"

        mkdir -p "$HOME/bin"

        cat <<EOF > "$HOME/bin/baksmali"
#!/bin/sh
java -jar \$HOME/baksmali.jar "\$@"
EOF

        cat <<EOF > "$HOME/bin/smali"
#!/bin/sh
java -jar \$HOME/smali.jar "\$@"
EOF

        chmod +x "$HOME/bin/baksmali" "$HOME/bin/smali"

        if ! grep -q 'export PATH="\$HOME/bin:\$PATH"' "$HOME/.bashrc"; then
            echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
            source "$HOME/.bashrc"
        fi

        echo "[*] Smali/Baksmali instalados com sucesso! Reinicie o terminal ou execute 'source ~/.bashrc'."
    else
        echo "[*] Smali/Baksmali já estão instalados"
    fi
}

if [ $# -eq 0 ]; then
    echo "Nenhum argumento fornecido. Instalando tudo..."
    install_base_dependencies
    append_env_vars
    open_firewall_ports
    install_genymotion
    install_burpsuite
    install_apktool
    install_jadx_gui
    install_frida
    install_smali_tools
else
    for arg in "$@"; do
        case $arg in
            --install-deps) install_base_dependencies ;;
            --env) append_env_vars ;;
            --ports) open_firewall_ports ;;
            --install-genymotion) install_genymotion ;;
            --install-burpsuite) install_burpsuite ;;
            --install-apktool) install_apktool ;;
            --install-jadx) install_jadx_gui ;;
            --install-frida) install_frida ;;
            --install-smali) install_smali_tools ;;
            --install-all)
                install_base_dependencies
                append_env_vars
                open_firewall_ports
                install_genymotion
                install_burpsuite
                install_apktool
                install_jadx_gui
                install_frida
                install_smali_tools
                ;;
            *)
                echo "[!] Argumento inválido: $arg"
                ;;
        esac
    done
fi

exec bash --login
