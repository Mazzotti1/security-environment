import os
import pyaes
import argparse

def decrypt_file(file_name, key, output_file):
    try:
        with open(file_name, "rb") as file:
            file_data = file.read()
    except FileNotFoundError:
        print(f"Erro: Arquivo '{file_name}' não encontrado.")
        return

    aes = pyaes.AESModeOfOperationCTR(key)
    decrypted_data = aes.decrypt(file_data)

    os.remove(file_name)

    with open(output_file, "wb") as new_file:
        new_file.write(decrypted_data)

    print(f"Arquivo '{file_name}' descriptografado com sucesso como '{output_file}'.")

def main():
    parser = argparse.ArgumentParser(description="Descriptografar arquivos.")
    parser.add_argument('file_name', help="Caminho do arquivo a ser descriptografado")
    parser.add_argument('key', help="Chave de descriptografia", type=str)
    parser.add_argument('output_file', help="Nome do arquivo descriptografado de saída", type=str)
    args = parser.parse_args()

    decrypt_file(args.file_name, args.key.encode(), args.output_file)

if __name__ == "__main__":
    main()


# python decrypter.py arquivo_criptografado.bin minha_chave_senha arquivo_descriptografado.txt
