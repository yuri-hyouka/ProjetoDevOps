# Projeto DevOps: Pipeline CI/CD Completo na AWS

Este projeto demonstra a criação de uma esteira de CI/CD (Integração e Entrega Contínua) completa, desde o provisionamento da infraestrutura na nuvem até o deploy automatizado de uma aplicação web containerizada.

O objetivo é aplicar conceitos e ferramentas fundamentais de DevOps para construir um fluxo de trabalho robusto, seguro e 100% automatizado.

## Arquitetura do Projeto

O fluxo de automação funciona da seguinte maneira:

1.  **Desenvolvedor**: Realiza um `git push` para a branch `main` no repositório do GitHub.
2.  **GitHub Actions (CI)**: O push aciona o workflow de Integração Contínua.
    - A imagem Docker da aplicação é construída.
    - Um teste de integração é executado, subindo a aplicação e o Redis com `docker compose` para validar o endpoint `/health`.
    - Se o teste passar, a imagem é enviada para o **Docker Hub** com tags de versão.
3.  **GitHub Actions (CD)**: Após o sucesso do CI, o workflow de Entrega Contínua é acionado.
    - Ele se conecta via SSH à instância **EC2 na AWS**.
    - Copia o arquivo `docker-compose.yml` atualizado.
    - Executa `docker compose pull` para baixar a nova imagem do Docker Hub.
    - Executa `docker compose up -d` para reiniciar a aplicação com a nova versão, sem downtime perceptível.

## Tecnologias Utilizadas

*   **Nuvem**: AWS (Amazon Web Services)
*   **Infraestrutura como Código (IaC)**: Terraform
*   **Gerenciamento de Configuração**: Ansible
*   **Containerização**: Docker & Docker Compose
*   **Aplicação**: Python (Flask) + Redis
*   **CI/CD**: GitHub Actions
*   **Registro de Imagens**: Docker Hub

---

## Passo a Passo do Projeto

### 1. Infraestrutura como Código com Terraform

O diretório `terraform/` contém o código para provisionar a infraestrutura base na AWS.

*   **`main.tf`**:
    *   Cria uma instância **EC2** `t2.micro` com uma AMI Debian.
    *   Cria um **Security Group** que libera as portas `22` (SSH), `80` (HTTP) e `5000` (App).
    *   Utiliza `data sources` para buscar a VPC e a Subnet padrão da conta, tornando o código mais portável.

### 2. Gerenciamento de Configuração com Ansible

O diretório `ansible/` é responsável por configurar o servidor provisionado.

*   **`provisioning.yml`**: O playbook principal que aplica as configurações.
*   **`roles/docker/`**: Uma *role* dedicada e reutilizável que instala o Docker Engine e o plugin do Docker Compose na instância EC2, seguindo as melhores práticas de organização do Ansible.

### 3. Aplicação e Containerização

*   **`app/main.py`**: Uma API simples em Flask com 3 endpoints:
    *   `GET /`: Página principal que incrementa um contador no Redis.
    *   `GET /health`: Verifica a conexão com o Redis, essencial para o monitoramento.
    *   `GET /metrics`: Exibe o total de acessos, lendo o contador do Redis.
*   **`Dockerfile`**: Define a receita para construir a imagem da aplicação. Utiliza uma imagem base `python-alpine` para ser leve e segue boas práticas como a cópia do `requirements.txt` em uma camada separada para otimizar o cache.
*   **`docker-compose.yml`**: Orquestra a execução da aplicação e do banco de dados Redis. Define os serviços, volumes para persistência de dados do Redis e a rede para comunicação entre os contêineres.

### 4. Automação com GitHub Actions

O diretório `.github/workflows/` contém o coração da automação.

*   **Job `build-test-and-push` (CI)**:
    1.  **Build**: Constrói a imagem Docker a partir do `Dockerfile`.
    2.  **Test**: Executa `docker compose up` para subir a aplicação e o Redis em um ambiente de teste. Um script verifica se o endpoint `/health` retorna o status `UP`, garantindo que a aplicação e sua dependência estão funcionando juntas.
    3.  **Push**: Se o teste passar, a imagem é tagueada com o SHA do commit e com a tag `latest`, e então enviada para o Docker Hub.
*   **Job `deploy` (CD)**:
    1.  **Needs CI**: Só é executado após o sucesso do job de CI.
    2.  **Connect**: Conecta-se à instância EC2 via SSH.
    3.  **Deploy**: Copia o `docker-compose.yml` para o servidor e executa os comandos `docker compose pull` e `docker compose up -d`. O Docker Compose inteligentemente recria apenas o contêiner da aplicação, mantendo o de Redis intacto.

## Como Executar

1.  **Pré-requisitos**:
    *   Conta na AWS.
    *   Terraform e Ansible instalados localmente.
    *   Conta no Docker Hub.
    *   Chave SSH registrada na sua conta AWS com o nome `iac-alura`.

2.  **Configuração de Segredos no GitHub**:
    *   No seu repositório, vá em `Settings > Secrets and variables > Actions` e adicione os seguintes segredos:
        *   `DOCKERHUB_USERNAME`: Seu usuário do Docker Hub.
        *   `DOCKERHUB_TOKEN`: Um token de acesso do Docker Hub.
        *   `EC2_HOST`: O IP público da instância EC2 (será gerado pelo Terraform).
        *   `EC2_USER`: O usuário da instância (ex: `admin` para Debian).
        *   `EC2_PRIVATE_KEY`: O conteúdo da sua chave SSH privada.

3.  **Provisionamento (Execução Manual Inicial)**:
    *   **Terraform**:
        ```bash
        cd terraform
        terraform init
        terraform apply
        ```
    *   **Ansible**:
        ```bash
        cd ansible
        # Adicione o IP da sua instância no arquivo 'hosts'
        ansible-playbook -i hosts provisioning.yml
        ```

4.  **Fluxo Automatizado**:
    *   Após o provisionamento inicial, qualquer `git push` na branch `main` irá disparar o pipeline de CI/CD e implantar a nova versão automaticamente.