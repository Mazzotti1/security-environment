#!/bin/bash

echo "[+] Iniciando Tor..."
tor &

# Aguarda o Tor subir (pode ajustar esse tempo ou fazer verificação de porta)
sleep 10

echo "[+] Iniciando Privoxy..."
privoxy /etc/privoxy/config &

# Aguarda o Privoxy subir
sleep 5

echo "[+] Iniciando Squid..."
squid -f /etc/squid/squid.conf -N
