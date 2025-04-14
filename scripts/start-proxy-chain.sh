#!/bin/bash

echo "[+] Iniciando Tor..."
tor &

sleep 10

echo "[+] Iniciando Privoxy..."
privoxy /etc/privoxy/config &

sleep 5

echo "[+] Iniciando Squid..."
squid -f /etc/squid/squid.conf -N
