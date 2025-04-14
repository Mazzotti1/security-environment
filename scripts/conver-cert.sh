
# Verificar se o certificado foi fornecido como argumento
if [ -z "$1" ]; then
  echo "Uso: $0 <certificado.cer>"
  exit 1
fi

# Definir o nome do arquivo do certificado e do arquivo .pem
CERTIFICADO="$1"
CERTIFICADO_PEM="${CERTIFICADO%.cer}.pem"
CERTIFICADO_HASH="hash.0"

# Verificar se o arquivo de certificado existe
if [ ! -f "$CERTIFICADO" ]; then
  echo "Certificado não encontrado: $CERTIFICADO"
  exit 1
fi

# Converter o certificado de DER para PEM
echo "Convertendo o certificado de DER para PEM..."
openssl x509 -inform DER -in "$CERTIFICADO" -out "$CERTIFICADO_PEM"

# Verificar se a conversão para PEM foi bem-sucedida
if [ $? -ne 0 ]; then
  echo "Erro na conversão para PEM"
  exit 1
fi

# Obter o hash do certificado em formato de nome de arquivo (hash.0)
echo "Gerando o hash do certificado..."
CERTIFICADO_HASH_RESULTADO=$(openssl x509 -inform PEM -subject_hash_old -in "$CERTIFICADO_PEM" | head -1)

# Verificar se o comando para gerar o hash foi bem-sucedido
if [ $? -ne 0 ]; then
  echo "Erro ao gerar o hash do certificado"
  exit 1
fi

# Renomear o arquivo PEM para o formato de hash.0
echo "Renomeando o certificado para hash.0..."
mv "$CERTIFICADO_PEM" "$CERTIFICADO_HASH"

echo "Processo concluído: O certificado foi convertido e renomeado para '$CERTIFICADO_HASH'."
