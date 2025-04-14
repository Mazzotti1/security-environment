
# ------------------------------
# APK Unsigner - por mazzotti
# ------------------------------

set -e

APK="$1"

if [ -z "$APK" ]; then
  echo "Uso: $0 arquivo.apk"
  exit 1
fi

if [ ! -f "$APK" ]; then
  echo "ERRO: Arquivo não encontrado: $APK"
  exit 1
fi

if [[ "$APK" != *.apk ]]; then
  echo "ERRO: O arquivo fornecido não parece ser um APK."
  exit 1
fi

echo "[*] Removendo assinatura do APK..."

# Backup do APK original
BACKUP="${APK%.apk}_original.apk"
cp "$APK" "$BACKUP"
echo "[*] Backup criado: $BACKUP"

# Remover assinatura
zip -d "$APK" META-INF/\* > /dev/null

if [ $? -eq 0 ]; then
  echo "[✓] Assinatura removida com sucesso de: $APK"
else
  echo "[!] Falha ao remover a assinatura."
  exit 1
fi
