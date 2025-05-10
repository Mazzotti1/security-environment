
check_dependency() {
  if ! command -v "$1" &> /dev/null; then
    echo "ERRO: O comando '$1' não está instalado."
    echo "Instale o '$1' antes de continuar:"
    echo "  - No Linux: sudo apt install openjdk-11-jdk (ou versão mais recente)"
    exit 1
  fi
}

echo "Verificando dependências..."
check_dependency "keytool"
check_dependency "jarsigner"

if [ "$1" == "" ]; then
  echo "<=========================================>"
  echo "Mazzotti"
  echo "Modo de usar: $0 meuapkalterado.apk"
  echo "<=========================================>"
else
  echo "<=========================================>"
  echo "Assinatura de APKs"
  echo "<=========================================>"

  echo "Digite um nome simples para o arquivo keystore (ex: mazzotti):"
  read nome

  if [ -f "$nome.jks" ]; then
    echo "O keystore $nome.jks já existe. Deseja usá-lo? (s/n)"
    read resposta
    if [ "$resposta" == "n" ]; then
      echo "Digite um novo nome para o keystore:"
      read nome
    fi
  fi

  echo "Digite uma senha com pelo menos 8 caracteres (ex: minhasenha):"
  read senha

  if [ ! -f "$nome.jks" ]; then
    echo "Gerando arquivo de keystore para assinatura..."
    keytool -genkeypair -v \
      -keystore "$nome.jks" \
      -storepass "$senha" \
      -keypass "$senha" \
      -alias "$nome" \
      -keyalg RSA -keysize 2048 -validity 10000 \
      -dname "CN=MAZZOTTI"
  fi

  jarsigner -verify -verbose -certs "$1" > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "O APK $1 já está assinado. Deseja sobrescrever a assinatura? (s/n)"
    read resposta
    if [ "$resposta" == "n" ]; then
      echo "Abortando..."
      exit 1
    fi
  fi

  cp "$1" "${1%.apk}_backup.apk"
  echo "Backup criado: ${1%.apk}_backup.apk"

  echo "Assinando o APK com jarsigner..."
  jarsigner -keystore "$nome.jks" \
    -storepass "$senha" \
    -keypass "$senha" \
    -sigalg SHA256withRSA \
    -digestalg SHA-256 \
    -tsa http://timestamp.digicert.com \
    "$1" "$nome"

  echo "Verificando assinatura..."
  jarsigner -verify -verbose -certs "$1"

  echo "<=========================================>"
  echo "Processo concluído! APK assinado: $1"
  echo "<=========================================>"
fi
