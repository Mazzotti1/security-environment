FROM ubuntu:latest

# Atualiza e instala pacotes necessários
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    python3 \
    python3-pip \
    openjdk-11-jdk \
    adb \
    net-tools \
    gnupg \
    lsb-release \
    x11vnc \
    unzip \
    libusb-1.0-0-dev \
    libc6 \
    squid \
    privoxy \
    libxtst6 \
    libxrender1 \
    libxi6 \
    libgtk-3-0 \
    && apt-get clean

# ==================== VARIÁVEIS DE AMBIENTE ====================
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV ANDROID_HOME=/opt/android-sdk
ENV GENYMOTION_HOME=/opt/genymotion
ENV BURP_SUITE_HOME=/opt/burpsuite
ENV PATH="${JAVA_HOME}/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${GENYMOTION_HOME}:${BURP_SUITE_HOME}:${PATH}"

# Configuração do SDK do Android e Platform Tools
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O /tmp/cmdline-tools.zip && \
    mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    unzip /tmp/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools && \
    mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip && \
    yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --licenses && \
    ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager "platform-tools" "build-tools;30.0.3" && \
    ln -sf ${ANDROID_HOME}/platform-tools/adb /usr/local/bin/adb && \
    ln -sf ${ANDROID_HOME}/platform-tools/fastboot /usr/local/bin/fastboot

# Configuração do TOR
RUN echo "deb http://deb.torproject.org/torproject.org stretch main" | tee /etc/apt/sources.list.d/tor.list && \
    curl -fsSL https://www.torproject.org/dist/torbrowser/10.0.17/tor-browser-linux64-10.0.17_en-US.tar.xz -o /tmp/tor-browser.tar.xz && \
    tar -xvf /tmp/tor-browser.tar.xz -C /opt && \
    mv /opt/tor-browser_en-US /opt/tor-browser && \
    rm /tmp/tor-browser.tar.xz

# Configuração de proxy
COPY proxy-chain/torrc /etc/tor/torrc
COPY proxy-chain/squid.conf /etc/squid/squid.conf
COPY proxy-chain/privoxy.conf /etc/privoxy/config

# Instalação do Genymotion
RUN wget https://dl.genymotion.com/genymotion-3.1.2-linux_x64.bin -O /tmp/genymotion-installer.bin && \
    chmod +x /tmp/genymotion-installer.bin && \
    /tmp/genymotion-installer.bin -y -d /opt/genymotion && \
    rm /tmp/genymotion-installer.bin && \
    # Cria wrapper para o Genymotion
    echo '#!/bin/sh\ncd /opt/genymotion && ./genymotion &' > /usr/local/bin/genymotion && \
    chmod +x /usr/local/bin/genymotion

# APKTool
RUN wget https://github.com/iBotPeaches/Apktool/releases/download/v2.5.0/apktool_2.5.0.jar -O /opt/apktool.jar && \
    echo '#!/bin/sh\njava -jar /opt/apktool.jar "$@"' > /usr/local/bin/apktool && \
    chmod +x /usr/local/bin/apktool

# Jadx
RUN wget https://github.com/skylot/jadx/releases/download/v1.3.0/jadx-1.3.0.zip -O /tmp/jadx.zip && \
    unzip /tmp/jadx.zip -d /opt/jadx && \
    rm /tmp/jadx.zip && \
    ln -s /opt/jadx/bin/jadx /usr/local/bin/jadx && \
    ln -s /opt/jadx/bin/jadx-gui /usr/local/bin/jadx-gui

# Burp Suite Community Edition
RUN wget "https://portswigger.net/burp/releases/download?product=community&version=2023.12.1.1&type=Linux" -O /tmp/burpsuite.sh && \
    chmod +x /tmp/burpsuite.sh && \
    /tmp/burpsuite.sh -q -dir /opt/burpsuite && \
    rm /tmp/burpsuite.sh && \
    echo '#!/bin/sh\njava -jar /opt/burpsuite/BurpSuiteCommunity.jar &' > /usr/local/bin/burpsuite && \
    chmod +x /usr/local/bin/burpsuite

# Instalação de dependências Python
RUN pip3 install frida-tools pyaes reflutter && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Configuração de scripts e ferramentas
COPY scripts/ /app/scripts/
COPY cript/ /app/cript/
COPY bypass/ /app/bypass/
COPY baksmali-2.5.2.jar /tools/baksmali.jar

# Configuração do Baksmali
RUN echo '#!/bin/sh\njava -jar /tools/baksmali.jar "$@"' > /usr/local/bin/baksmali && \
    chmod +x /usr/local/bin/baksmali

# Configuração do APK signer
RUN mkdir -p /app/apk-signers/uber-apk-signer && \
    curl -L -o /app/apk-signers/uber-apk-signer/uber-apk-signer.jar \
    https://github.com/patrickfav/uber-apk-signer/releases/download/v1.3.0/uber-apk-signer-1.3.0.jar && \
    echo '#!/bin/sh\njava -jar /app/apk-signers/uber-apk-signer/uber-apk-signer.jar "$@"' > /usr/local/bin/uber-apk-signer && \
    chmod +x /usr/local/bin/uber-apk-signer

# Configuração de chaves
RUN mkdir -p /app/apk-signers/keys && \
    keytool -genkey -v -keystore /app/apk-signers/keys/keystore.jks \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias androiddebugkey \
    -storepass android -keypass android \
    -dname "CN=Android Debug,O=Android,C=US"

# Configuração de permissões e links
RUN chmod +x /app/scripts/*.sh && \
    ln -s /app/scripts/sign-apk.sh /usr/local/bin/sign-apk && \
    ln -s /app/scripts/unsign-apk.sh /usr/local/bin/unsign-apk && \
    ln -s /app/scripts/start-proxy-chain.sh /usr/local/bin/start-proxy-chain && \
    ln -s /app/scripts/convert-cert.sh /usr/local/bin/convert-cert

# Cria aliases para facilitar o uso
RUN echo "alias start-genymotion='cd /opt/genymotion && ./genymotion &'" >> ~/.bashrc && \
    echo "alias start-burp='java -jar /opt/burpsuite/BurpSuiteCommunity.jar &'" >> ~/.bashrc && \
    echo "alias start-tor='/opt/tor-browser/start-tor-browser &'" >> ~/.bashrc && \
    echo "alias start-jadx='jadx-gui &'" >> ~/.bashrc

# Variáveis adicionais para ferramentas
ENV APKTOOL_PATH=/opt/apktool.jar
ENV BAKSMALI_PATH=/tools/baksmali.jar
ENV UBER_SIGNER_PATH=/app/apk-signers/uber-apk-signer/uber-apk-signer.jar
ENV KEYSTORE_PATH=/app/apk-signers/keys/keystore.jks
ENV KEYSTORE_PASS=android
ENV KEY_ALIAS=androiddebugkey
ENV KEY_PASS=android
ENV PATH="/opt/tor-browser:/opt/jadx/bin:/opt/burpsuite:/opt/genymotion:${PATH}"

EXPOSE 1080 8118 3128 9050

WORKDIR /app

CMD ["bash", "--login"]