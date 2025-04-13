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
    && apt-get clean

# TOR
RUN if [ ! -d /opt/tor-browser ]; then \
    echo "deb http://deb.torproject.org/torproject.org stretch main" | tee /etc/apt/sources.list.d/tor.list && \
    curl -fsSL https://www.torproject.org/dist/torbrowser/10.0.17/tor-browser-linux64-10.0.17_en-US.tar.xz -o /tmp/tor-browser.tar.xz && \
    tar -xvf /tmp/tor-browser.tar.xz -C /opt && \
    mv /opt/tor-browser_en-US /opt/tor-browser && \
    rm /tmp/tor-browser.tar.xz; \
    fi
COPY proxy-chain/torrc /etc/tor/torrc

# Squid
RUN if [ ! -f /usr/sbin/squid ]; then \
    apt-get update && apt-get install -y squid && \
    apt-get clean; \
    fi
COPY proxy-chain/squid.conf /etc/squid/squid.conf

# Privoxy
RUN if [ ! -f /usr/sbin/privoxy ]; then \
    apt-get update && apt-get install -y privoxy && \
    apt-get clean; \
    fi
COPY proxy-chain/privoxy.conf /etc/privoxy/config

# Genymotion
RUN if [ ! -d /opt/genymotion ]; then \
    wget https://dl.genymotion.com/genymotion-3.1.2-linux_x64.bin -O /opt/genymotion-installer.bin && \
    chmod +x /opt/genymotion-installer.bin && \
    /opt/genymotion-installer.bin && \
    rm /opt/genymotion-installer.bin; \
    fi

# APKTool
RUN if [ ! -f /opt/apktool.jar ]; then \
    wget https://github.com/iBotPeaches/Apktool/releases/download/v2.5.0/apktool_2.5.0.jar -O /opt/apktool.jar; \
    fi

# Jadx GUI
RUN if [ ! -d /opt/jadx ]; then \
    wget https://github.com/skylot/jadx/releases/download/v1.3.0/jadx-1.3.0.zip -O /tmp/jadx.zip && \
    unzip /tmp/jadx.zip -d /opt/jadx && \
    rm /tmp/jadx.zip; \
    fi

# Burp Suite Community Edition
RUN if [ ! -f /opt/burpsuite/BurpSuiteCommunity ]; then \
    wget https://portswigger.net/burp/releases/download?product=community&version=2023.12.1.1&type=Linux -O /tmp/burpsuite.sh && \
    chmod +x /tmp/burpsuite.sh && \
    /tmp/burpsuite.sh -q -dir /opt/burpsuite && \
    rm /tmp/burpsuite.sh; \
    fi

# Android Platform Tools
RUN if [ ! -d /opt/platform-tools ]; then \
    wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip -O /tmp/platform-tools.zip && \
    unzip /tmp/platform-tools.zip -d /opt && \
    rm /tmp/platform-tools.zip && \
    ln -sf /opt/platform-tools/adb /usr/local/bin/adb && \
    ln -sf /opt/platform-tools/fastboot /usr/local/bin/fastboot; \
    fi

# Instalar Frida
RUN pip3 install frida-tools
RUN pip3 install pyaes
COPY cript /app/cript

# Start proxy chain
COPY scripts/start-proxy-chain.sh /usr/local/bin/start-proxy-chain.sh
RUN chmod +x /usr/local/bin/start-proxy-chain.sh

EXPOSE 1080 8118 3128 9050

ENTRYPOINT ["/bin/bash"]
