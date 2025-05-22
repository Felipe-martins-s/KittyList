# Kitty List

Um aplicativo simples de lista de tarefas desenvolvido em Flutter.

## Funcionalidades

*   Adicionar novas tarefas.
*   Marcar tarefas como concluídas (texto riscado).
*   Remover tarefas.
*   Persistência local dos dados usando Hive.
*   Background personalizado.

## Como Executar o Projeto

1.  Certifique-se de ter o Flutter SDK instalado e configurado em sua máquina.
2.  Clone este repositório (ou baixe os arquivos do projeto).
3.  Navegue até a pasta raiz do projeto no terminal (`KittyList`).
4.  Execute `flutter pub get` para baixar as dependências do projeto.
5.  Execute `flutter packages pub run build_runner build` para gerar os arquivos necessários do Hive.
6.  Conecte um dispositivo Android/iOS ou inicie um emulador/simulador.
7.  No Android Studio (ou VS Code), selecione o dispositivo e clique no botão Run (ou execute `flutter run` no terminal).

## Estrutura do Projeto

*   `lib/main.dart`: O arquivo principal que contém a lógica da UI e interage com o Hive.
*   `lib/models/task.dart`: Define o modelo de dados para uma tarefa.
*   `assets/images/`: Pasta para as imagens do aplicativo (como o background e o ícone).
*   `assets/fonts/`: Pasta para fontes personalizadas (se adicionadas).
*   `pubspec.yaml`: Arquivo de configuração do projeto e gerenciamento de dependências.

## Dependências Principais

*   `flutter`: SDK do Flutter.
*   `hive`, `hive_flutter`: Banco de dados NoSQL local.
*   `flutter_launcher_icons`: Para gerar ícones de aplicativo.

## Autor

Felipe MS
