# Kitty List

Um aplicativo de lista de tarefas desenvolvido em Flutter com interface amigável e persistência local de dados.

## Funcionalidades

* Adicionar novas tarefas
* Marcar tarefas como concluídas (texto riscado)
* Editar tarefas tocando no item da lista
* Confirmação antes de remover tarefas para evitar exclusões acidentais
* Remover tarefas
* Visualização separada de tarefas a fazer e tarefas concluídas
* Persistência local dos dados usando Hive
* Interface com background personalizado
* Suporte a gestos e interações intuitivas

## Como Executar o Projeto

1. Certifique-se de ter o Flutter SDK instalado e configurado em sua máquina
2. Clone este repositório (ou baixe os arquivos do projeto)
3. Navegue até a pasta raiz do projeto no terminal (`KittyList`)
4. Execute `flutter pub get` para baixar as dependências do projeto
5. Execute `flutter packages pub run build_runner build` para gerar os arquivos necessários do Hive
   - **Importante:** Execute este comando novamente se modificar a estrutura da classe `Task` (lib/models/task.dart)
6. Conecte um dispositivo Android/iOS ou inicie um emulador/simulador
7. No Android Studio (ou VS Code), selecione o dispositivo e clique no botão Run (ou execute `flutter run` no terminal)

## Estrutura do Projeto

* `lib/main.dart`: Arquivo principal com a lógica da UI e interação com o Hive
* `lib/models/task.dart`: Define o modelo de dados para uma tarefa
* `assets/images/`: Pasta para as imagens do aplicativo (background e ícone)
* `assets/fonts/`: Pasta para fontes personalizadas
* `pubspec.yaml`: Configuração do projeto e gerenciamento de dependências

## Dependências Principais

* `flutter`: SDK do Flutter
* `hive`, `hive_flutter`: Banco de dados para salvar as tarefas
* `flutter_launcher_icons`: Para gerar os ícones do app

## Comandos Importantes

* `flutter pub get`: Baixa as dependências do projeto
* `flutter packages pub run build_runner build`: Gera arquivos de código necessários
* `flutter pub run flutter_launcher_icons`: Gera os ícones do aplicativo

## Autores

Acadêmicos de ADS da Univinte:
- Ana Carolina Bitencourt
- Ewellin Barreto
- Felipe Martins
- Manoel Vitor
- Patrick Luiz Farias
- Vitória Silva

## Documentação

Para mais detalhes sobre a implementação e estrutura do projeto, consulte o arquivo `DOCUMENTATION.txt` na raiz do projeto.

