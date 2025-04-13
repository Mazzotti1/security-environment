import os
import pyaes
import argparse

def encrypt_file(file_name, key, output_file):
    try:
        with open(file_name, "rb") as file:
            file_data = file.read()
    except FileNotFoundError:
        print(f"Erro: Arquivo '{file_name}' não encontrado.")
        return

    aes = pyaes.AESModeOfOperationCTR(key)
    crypto_data = aes.encrypt(file_data)

    with open(output_file, 'wb') as new_file:
        new_file.write(crypto_data)

    os.remove(file_name)

    print(f"Arquivo '{file_name}' criptografado com sucesso como '{output_file}'.")

def main():
    parser = argparse.ArgumentParser(description="Criptografar arquivos.")
    parser.add_argument('file_name', help="Caminho do arquivo a ser criptografado")
    parser.add_argument('key', help="Chave de criptografia", type=str)
    parser.add_argument('output_file', help="Nome do arquivo criptografado de saída", type=str)
    args = parser.parse_args()

    encrypt_file(args.file_name, args.key.encode(), args.output_file)

if __name__ == "__main__":
    main()

#python encrypter.py arquivo.txt minha_chave_senha arquivo_criptografado.bin
