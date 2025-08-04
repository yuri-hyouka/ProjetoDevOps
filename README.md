# ProjetoDevOps
Autor: Yuri Ferreira
Data Inicio: 30/07/2025
Projeto DevOps: Infraestrutura Completa com Terraform, Ansible, Docker, Python e GitHub Actions

# A Cloud utilizada neste projeto foi AWS
# Para provisionamento da Infraestrutura foi utilizado Terraform e Ansible

1 - TERRAFORM
    - Diretório: /terraform
    - Utilizado o terraform para:
        - Buscar a VPC e a SUBNET Default da Conta na AWS
        - Criar  uma instância EC2
        - Criar  o grupo de segurança aws_security_group
        - Incluir as regras de Ingress e Egress para liberação de acesso HTTP e SSH

2 - ANSIBLE
    - Diretório: /ansible
    - Utilizado o ansible para instalar o Docker no servidor provisionado
    - Como boa prática, a tarefa de instalação do Docker foi definida como "Role" no diretório ansible/roles/docker/tasks
    - Foi definido o arquivo de hosts e no playbook principal foi definido qual host e qual role seriam utilizados
    - Para conexão no host remoto foi utilizado a chave privada que não será versionada.

3 - APP
    - diretório: /APP
    - API Web Simples construída com o micro-framework Flask em Python. A principal função dela é servir como um exemplo de aplicação para um ambiente DevOps,
      demonstrando boas práticas como health checks e métricas. Ela usa um banco de dados Redis para persistir um contador.
    - A aplicação expoe tres rotas(endpoints):
        - GET /
            - A cada acesso a esta rota, ela tenta incrementar um contador chamado access_count no Redis. Se a conexão com o Redis falhar, a aplicação não quebra e a mensagem é exibida normalmente.
        - GET /health
            - Verifica a "saúde" da aplicação, que neste caso está diretamente ligada à sua capacidade de se comunicar com o Redis.
                Retorno:
                {"status": "UP"} se a conexão com o Redis for bem-sucedida.
                {"status": "DOWN"} se não conseguir se conectar ao Redis.
        - GET /metrics
            - Retorna um JSON com a contagem total de acessos à rota raiz, buscando o valor da chave access_count no Redis. Ex: {"access_count": 10}

4 - DOCKER
    - Diretório: /
    - Files: Dockerfile, Docker-compose.yml e requirements.txt
        - Dockerfile
            - Define o diretório de trabalho, a instalação dos requisitos, expoe a porta de acesso e define o comando para iniciar a aplicação usando Gunicorn.
        - Docker-compose.yml
            - Define quais container irão subir(app, redis) e suas informações, volumes, variaveis de ambiente, versão da imagem e porta de acesso.
        - requirements.txt
            - Define quais são os requisitos para a aplicação funcioanr

5 - GITHUB ACTIONS(CI)
    - Fazer o checkout do seu código-fonte.
    - Encontrar o Dockerfile e o código da aplicação.
    - Executar o comando docker build para criar a imagem.
    - Taguear a imagem com uma versão (yuripaixao/hc-devops:latest).
    - Executar docker push para enviar essa imagem recém-construída para o Docker Hub.

6 - GITHUB ACTIONS(CD)
    - A responsabilidade do seu playbook do Ansible, que é a etapa de deploy, é:
    - Conectar-se ao seu servidor EC2.
    - Copiar o arquivo docker-compose.yml do seu repositório para o servidor.
    - Instalar o Docker no servidor.
    - Executar docker-compose up.


    
