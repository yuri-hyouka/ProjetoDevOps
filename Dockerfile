# Use uma imagem Python oficial baseada em Alpine.
# Alpine Linux é muito menor que a maioria das imagens de distribuição, o que ajuda a manter as imagens finais pequenas.
# Usar uma tag específica (ex: 3.10-alpine) garante builds reproduzíveis.
FROM python:3.10-alpine

# Define o diretório de trabalho dentro do contêiner.
# Isso garante que os comandos subsequentes sejam executados neste diretório.
WORKDIR /app

# Copia o arquivo de dependências primeiro.
# Isso aproveita o cache de camadas do Docker. A camada de instalação de dependências
# só será reconstruída se o arquivo requirements.txt mudar.
COPY requirements.txt .

# Instala as dependências do projeto.
# --no-cache-dir desabilita o cache do pip(reduzindo o tamanho).
RUN pip install --no-cache-dir -r requirements.txt

# Copia o código da aplicação para o diretório de trabalho.
COPY app/ .

# Expõe a porta em que o aplicativo será executado.
EXPOSE 5000

# Comando para iniciar a aplicação usando Gunicorn.
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "main:app"]