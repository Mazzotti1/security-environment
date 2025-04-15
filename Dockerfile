FROM ubuntu:latest

# Atualiza e instala pacotes básicos necessários
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

# Variáveis de ambiente básicas
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH="${JAVA_HOME}/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${PATH}"

# Configuração do SDK do Android (essencial para muitas ferramentas)
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O /tmp/cmdline-tools.zip && \
    mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    unzip /tmp/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools && \
    mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip && \
    yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --licenses && \
    ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager "platform-tools" "build-tools;30.0.3" && \
    ln -sf ${ANDROID_HOME}/platform-tools/adb /usr/local/bin/adb && \
    ln -sf ${ANDROID_HOME}/platform-tools/fastboot /usr/local/bin/fastboot

# Configuração de proxy (básico)
COPY proxy-chain/torrc /etc/tor/torrc
COPY proxy-chain/squid.conf /etc/squid/squid.conf
COPY proxy-chain/privoxy.conf /etc/parivoxy/config

# Estrutura de diretórios
RUN mkdir -p /app/scripts /app/cript /app/bypass /tools /opt

# Scripts básicos
COPY scripts/ /app/scripts/
RUN chmod +x /app/scripts/*.sh

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

ENTRYPOINT ["/app/scripts/entrypoint.sh"]
CMD ["bash", "--login"]