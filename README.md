Parte 1 Projeto Mobile - prof. Diego

Abner Yohan Sato, 2459299
Ricardo Koji Takenaka, 2509857

### App de Gestão Clínica (Protótipo)
Um protótipo de aplicativo móvel desenvolvido em Flutter para a disciplina de desenvolvimento mobile. O projeto simula uma plataforma de gestão clínica simplificada, permitindo a interação entre dois tipos de perfis: Médico e Paciente.

##### ✨ Funcionalidades
O aplicativo atualmente implementa as seguintes funcionalidades:

Seleção de Perfil: Tela inicial que permite ao usuário "logar" como Médico ou Paciente.

Visão do Médico:

- Visualização da lista de todos os seus pacientes.

- Acesso aos prontuários detalhados de cada paciente.

- Criação de novos prontuários, com anotações e designação de tarefas.

Visão do Paciente:

- Visualização de uma lista de tarefas que foram designadas pelo médico.

- Checkbox para marcar tarefas como concluídas (atualmente apenas visual).

##### 📂 Estrutura do Projeto
O projeto segue uma estrutura baseada em padrões de design como MVC, separando as responsabilidades em diferentes diretórios:

1. /lib/models: Contém as classes que definem a estrutura de dados da aplicação (Usuário, Tarefa, Prontuário).

3. /lib/repositories: Centraliza a lógica de acesso aos dados, simulando um banco de dados em memória.

5. /lib/pages: Contém as telas (UI) da aplicação, separadas por contexto (comum, medico, paciente).

7. /lib/main.dart: Ponto de entrada principal da aplicação.

##### 🚀 Como Instalar e Rodar o Projeto
Para executar este projeto localmente, siga os passos abaixo.

Pré-requisitos
Flutter SDK: Instale o Flutter na sua máquina.

Um editor de código: VS Code com a extensão do Flutter ou Android Studio.

Um emulador Android ou iOS: Ou um dispositivo físico conectado.

Passos
Clone o repositório:

git clone [https://github.com/SatoYohan/Projeto-Mobile-Professor-Diego](https://github.com/SatoYohan/Projeto-Mobile-Professor-Diego)

Acesse o diretório do projeto:

cd Projeto-Mobile-Professor-Diego

Instale as dependências:
Execute o comando abaixo para baixar todos os pacotes necessários do projeto.

flutter pub get

Execute o aplicativo:
Certifique-se de que um emulador esteja rodando ou um dispositivo esteja conectado e execute:

flutter run

O aplicativo deverá ser compilado e iniciado no seu dispositivo/emulador.
