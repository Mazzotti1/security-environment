# Use a imagem base do Ubuntu
FROM ubuntu:latest

# Instala dependências básicas
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
    tshark \
    && apt-get clean

# Configura variáveis de ambiente preliminares
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 \
    ANDROID_HOME=/opt/android-sdk \
    GENYMOTION_HOME=/opt/genymotion \
    BURP_SUITE_HOME=/opt/burpsuite \
    APKTOOL_PATH=/opt/apktool.jar \
    BAKSMALI_PATH=/tools/baksmali.jar \
    UBER_SIGNER_PATH=/app/apk-signers/uber-apk-signer/uber-apk-signer.jar

# Configuração do TOR
RUN echo "deb http://deb.torproject.org/torproject.org stretch main" | tee /etc/apt/sources.list.d/tor.list && \
    curl -fsSL https://www.torproject.org/dist/torbrowser/10.0.17/tor-browser-linux64-10.0.17_en-US.tar.xz -O /tmp/tor-browser.tar.xz && \
    tar -xvf /tmp/tor-browser.tar.xz -C /opt && \
    mv /opt/tor-browser_en-US /opt/tor-browser && \
    rm /tmp/tor-browser.tar.xz

# Instala Android SDK Command Line Tools
RUN mkdir -p ${ANDROID_HOME} && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O /tmp/android-sdk.zip && \
    unzip /tmp/android-sdk.zip -d ${ANDROID_HOME} && \
    rm /tmp/android-sdk.zip && \
    mkdir -p ${ANDROID_HOME}/cmdline-tools/latest && \
    mv ${ANDROID_HOME}/cmdline-tools/* ${ANDROID_HOME}/cmdline-tools/latest/ && \
    yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --sdk_root=${ANDROID_HOME} --install "platform-tools" "build-tools;30.0.3" "platforms;android-30" && \
    chmod -R a+rwx ${ANDROID_HOME}

# Copia arquivos de configuração
COPY proxy-chain/ /etc/

# Instala dependências Python
RUN pip3 install pyaes frida-tools mitmproxy gplaycli

# Copia arquivos da aplicação
COPY crypt/ /app/crypt/
COPY bypass/ /app/bypass/
COPY scripts/ /app/scripts/
RUN chmod +x /app/scripts/*.sh

# Configura variáveis de ambiente restantes
ENV PATH="${JAVA_HOME}/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/latest/bin:${GENYMOTION_HOME}:${BURP_SUITE_HOME}:/opt/tor-browser:${PATH}"

# Configura o entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]