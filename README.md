Projeto Mobile (Flutter) - App de Gestão Clínica

Integrantes:

Abner Yohan Sato, 2459299

Ricardo Koji Takenaka, 2509857

📄 Descrição do Projeto

Este aplicativo, desenvolvido em Flutter para a disciplina de Desenvolvimento Mobile, simula uma plataforma de gestão clínica. Diferente da Parte 1 (que era um protótipo com dados em memória), esta versão é um aplicativo completo, conectado ao Google Firebase para autenticação de usuários e persistência de dados em tempo real com Cloud Firestore.

✨ Funcionalidades (Parte 2)

O aplicativo implementa um fluxo de usuário completo, desde o cadastro até a utilização das funções principais:

Sistema de Autenticação (Firebase Auth):

Criação de conta (Cadastro) com Nome, E-mail e Senha.

Login com E-mail e Senha.

Sessão persistente (o usuário continua logado ao fechar o app).

Botão de Logout.

Banco de Dados (Cloud Firestore):

Ao se cadastrar, todo usuário é criado como "paciente" por padrão.

O perfil do usuário (nome, e-mail, tipo) é salvo no Firestore.

Perfis de Usuário (Médico e Paciente):

O app direciona o usuário para a tela correta (Médico ou Paciente) após o login.

O usuário pode editar seu perfil, incluindo a mudança do tipo de "paciente" para "médico".

Visão do Médico:

Visualiza uma lista de todos os pacientes reais cadastrados no banco de dados.

CRUD de Prontuários:

(C)reate: Cria novos prontuários para qualquer paciente.

(R)ead: Vê a lista de prontuários em tempo real (usando StreamBuilder).

(D)elete: Deleta prontuários (arrastando para o lado).

Visão do Paciente:

(R)ead: Vê a lista de tarefas que seu médico lhe atribuiu, em tempo real.

(U)pdate: Pode marcar/desmarcar tarefas (o status é salvo no banco de dados).

📂 Estrutura do Projeto

O projeto foi refatorado para usar uma arquitetura mais robusta, separando a lógica de negócios da interface:

/lib/models: Define as classes de dados (Usuario, Prontuario, Tarefa) e como elas são convertidas de/para o Firestore.

/lib/services: Contém a lógica de backend, substituindo os repositórios falsos:

auth_service.dart: Gerencia Login, Cadastro e Logout.

firestore_service.dart: Gerencia todo o CRUD de Usuários, Prontuários e Tarefas.

/lib/pages: Contém as telas (UI), separadas por contexto (comum, medico, paciente).

/lib/main.dart: Ponto de entrada que inicializa o Firebase.

🚀 Como Instalar e Rodar (Obrigatório)

Este projeto usa o Firebase, que requer uma configuração de backend. Para rodar este projeto, você NÃO pode simplesmente clonar e rodar. Você DEVE conectá-lo ao seu próprio projeto Firebase.

O arquivo lib/firebase_options.dart (que contém as chaves da API) foi intencionalmente ignorado do repositório por segurança (através do .gitignore).

Siga estes 7 passos para rodar o projeto:

1. Clone o Repositório

# Clone este repositório
git clone [https://github.com/SatoYohan/Projeto-Mobile-Professor-Diego.git](https://github.com/SatoYohan/Projeto-Mobile-Professor-Diego.git)

# Acesse o diretório
cd Projeto-Mobile-Professor-Diego


2. Crie um Projeto no Firebase

Acesse o Console do Firebase.

Clique em "Adicionar projeto" e dê um nome a ele (ex: meu-app-clinica).

3. Habilite os Serviços do Firebase

No console do seu novo projeto, habilite os dois serviços que usamos:

Authentication:

No menu, vá em "Authentication" -> "Sign-in method".

Clique em "E-mail/Senha" e ative-o.

Firestore Database:

No menu, vá em "Firestore Database" -> "Criar banco de dados".

Inicie em Modo de Teste (permite leitura/escrita para testes).

4. Instale as Ferramentas de CLI (Firebase e FlutterFire)

Você precisará de duas ferramentas de linha de comando:

# 1. Instala o Node.js/npm (se você ainda não tem):
#    Acesse [https://nodejs.org/](https://nodejs.org/) e baixe a versão LTS.

# 2. Instala o Firebase CLI (via npm):
npm install -g firebase-tools

# 3. Instala o FlutterFire CLI (via Dart):
dart pub global activate flutterfire_cli


(Se os comandos firebase ou flutterfire não forem reconhecidos após a instalação, reinicie seu terminal ou computador).

5. Configure o Firebase no Projeto Flutter

Com as ferramentas instaladas, conecte seu projeto Flutter ao seu projeto Firebase:

# 1. Faça login na sua conta do Google (no terminal)
firebase login

# 2. Rode o comando de configuração do FlutterFire na raiz do projeto
#    (Ele vai perguntar qual projeto Firebase você quer usar)
flutterfire configure


Este comando vai se conectar ao Firebase, encontrar seu projeto meu-app-clinica e gerar automaticamente o arquivo lib/firebase_options.dart que estava faltando.

6. Instale as Dependências do Flutter

Agora que o projeto está configurado, instale os pacotes:

flutter pub get


7. Execute o Aplicativo

Pronto! Agora você pode rodar o app em um emulador ou dispositivo físico.

flutter run


O aplicativo será compilado e iniciado, conectado 100% ao seu backend do Firebase.