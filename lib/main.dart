// Importa a biblioteca principal do Flutter para criar interfaces de usuário.
import 'package:flutter/material.dart';
// Importa os pacotes do Hive para usar o banco de dados local.
import 'package:hive_flutter/hive_flutter.dart';
// Importa a definição da classe Task que criamos.
import 'models/task.dart';

// Função principal que inicializa o aplicativo.
// É assíncrona porque precisamos esperar a inicialização do Hive.
Future<void> main() async {
  // Inicializa o Hive, configurando-o para usar o sistema de arquivos do Flutter.
  await Hive.initFlutter();
  // Registra o adaptador para a classe Task, gerado automaticamente pelo build_runner.
  // Isso permite que o Hive saiba como ler e escrever objetos Task.
  Hive.registerAdapter(TaskAdapter());
  // Abre uma "box" do Hive (como uma tabela em outros bancos de dados) chamada 'tasksBox'.
  // Esta box armazenará nossos objetos Task.
  await Hive.openBox<Task>('tasksBox');

  // Inicia a execução do aplicativo Flutter com o widget MyApp como raiz.
  runApp(const MyApp());
}

// O widget raiz do nosso aplicativo.
// É um StatelessWidget porque não precisa manter estado mutável internamente.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp é o widget que configura a aparência e o roteamento básicos do app Material Design.
    return MaterialApp(
      // Título que aparece na barra de tarefas do sistema (não visível no app em si, mas usado pelo sistema).
      title: 'Kitty List',
      // Define o tema visual básico do aplicativo.
      theme: ThemeData(
        primarySwatch: Colors.blue, // Define a cor primária do tema.
      ),
      // Define a tela inicial do aplicativo.
      home: const TodoListScreen(),
    );
  }
}

// A tela principal onde a lista de tarefas será exibida e gerenciada.
// É um StatefulWidget porque o estado da lista de tarefas (adicionar/remover/marcar) mudará ao longo do tempo.
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

// O estado mutável da tela TodoListScreen.
// Contém os dados (a box do Hive) e a lógica para gerenciar as tarefas e a UI.
class _TodoListScreenState extends State<TodoListScreen> {
  // Referência para a box do Hive que armazena as tarefas.
  final _tasksBox = Hive.box<Task>('tasksBox');
  // Controlador para o campo de texto onde o usuário digita novas tarefas.
  final TextEditingController _textController = TextEditingController();
  // Node de foco para controlar o foco do campo de texto.
  // Usado para manter o campo ativo após adicionar uma tarefa.
  final FocusNode _textFieldFocusNode = FocusNode();

  // Método chamado uma vez quando o estado do widget é criado.
  @override
  void initState() {
    super.initState();
    // As tarefas são carregadas automaticamente pelo ValueListenableBuilder que escuta a box do Hive.
    // Não precisamos carregar manualmente uma lista aqui.
  }

  // Método para adicionar uma nova tarefa à lista (box do Hive).
  void _addTask(String title) {
    // Verifica se o título não está vazio antes de adicionar.
    if (title.isNotEmpty) {
      // Adiciona uma nova instância de Task à box do Hive.
      _tasksBox.add(Task(title: title));
      // Limpa o texto do campo de entrada.
      _textController.clear();
      // Solicita o foco de volta para o campo de texto para permitir adicionar outra tarefa.
      _textFieldFocusNode.requestFocus();
    }
  }

  // Método para marcar ou desmarcar uma tarefa como concluída.
  void _toggleTask(Task task) {
    // Inverte o estado isCompleted da tarefa.
    task.isCompleted = !task.isCompleted;
    // Salva as mudanças no objeto Task de volta para a box do Hive.
    task.save();
    // Força um redesenho do widget para garantir que a UI seja atualizada imediatamente.
    // Embora o Hive deva notificar, setState garante a atualização visual neste layout específico.
    setState(() {});
  }

  // Método para remover uma tarefa da lista (box do Hive).
  void _removeTask(Task task) {
    // Encontra o índice da tarefa na box para excluí-la corretamente.
    // Convertemos os valores da box para uma lista temporária para encontrar o índice.
    final int index = _tasksBox.values.toList().indexOf(task);
    // Verifica se a tarefa foi encontrada na lista.
    if (index != -1) {
      // Exclui a tarefa da box do Hive usando seu índice.
      // Isso também notificará os listeners.
      _tasksBox.deleteAt(index);
    }
    // Força um redesenho do widget para garantir que a UI seja atualizada imediatamente após a exclusão.
    setState(() {});
  }

  // O método build descreve a parte da UI representada por este widget.
  @override
  Widget build(BuildContext context) {
    // Obtém a altura do teclado virtual visível na tela.
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // Obtém a altura da barra de status do sistema no topo da tela.
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    // Define o espaço mínimo necessário na parte inferior da tela
    // quando o teclado está fechado. Este espaço é para a imagem de background
    // e para o título do aplicativo. Ajuste este valor conforme a sua imagem.
    const double reservedBottomSpace = 150.0;

    // Scaffold fornece a estrutura básica da tela (barra superior, corpo, etc.).
    return Scaffold(
      // Sem AppBar definida aqui, pois o título está na base.
      // O background transparente do Scaffold permite que a imagem de fundo apareça.
      body: Stack(
        // Stack permite empilhar widgets uns sobre os outros.
        children: [
          // Imagem de background que preenche todo o corpo do Scaffold.
          Positioned.fill(
            child: Image.asset(
              'assets/images/BackgroudBanco.png', // Caminho da imagem de background.
              fit: BoxFit.cover, // Cobre toda a área sem distorcer a proporção.
            ),
          ),
          // Contêiner que contém a área de input de tarefas e a lista de tarefas.
          // Envolvido por ValueListenableBuilder para reconstruir quando a box do Hive muda.
          ValueListenableBuilder(
            valueListenable: _tasksBox.listenable(), // Escuta as mudanças na tasksBox do Hive.
            builder: (context, box, _) { // Constrói a UI com base nos dados atuais da box.
              // Padding para criar espaço ao redor do conteúdo, ajustando para barra de status e área reservada.
              return Padding(
                padding: EdgeInsets.only(
                  // Espaço no topo: altura da barra de status + pequena margem.
                  top: statusBarHeight + 8.0,
                  // Espaço nas laterais.
                  left: 16.0,
                  right: 16.0,
                  // Espaço na base: reservado para a imagem de fundo e título.
                  bottom: reservedBottomSpace,
                ),
                // Contêiner com fundo cinza semi-transparente para a área de conteúdo.
                child: Container(
                  // Cor cinza com 40% de opacidade (mais transparente).
                  color: Colors.grey.withAlpha((255 * 0.4).round()),
                  // Column organiza os widgets verticalmente.
                  child: Column(
                    children: [
                      // Área de input (campo de texto e botão).
                      Row(
                        // Row organiza os widgets horizontalmente.
                        children: [
                          // Expanded faz o TextField ocupar o máximo de espaço horizontal disponível.
                          Expanded(
                            // Campo de texto para digitar novas tarefas.
                            child: TextField(
                              controller: _textController, // Liga o controlador ao campo.
                              focusNode: _textFieldFocusNode, // Liga o FocusNode para gerenciar o foco.
                              decoration: const InputDecoration(
                                hintText: 'Adicionar nova tarefa', // Texto de placeholder.
                                border: OutlineInputBorder(), // Borda ao redor do campo.
                              ),
                              // Chamado quando a tecla Enter é pressionada no campo.
                              onSubmitted: _addTask,
                            ),
                          ),
                          // Espaço horizontal entre o campo de texto e o botão.
                          const SizedBox(width: 16),
                          // Botão para adicionar a tarefa.
                          ElevatedButton(
                            // Chamado quando o botão é pressionado.
                            onPressed: () => _addTask(_textController.text),
                            child: const Text('Adicionar'),
                          ),
                        ],
                      ),
                      // Espaço vertical entre a área de input e a lista de tarefas.
                      const SizedBox(height: 16),
                      // Título para as tarefas a fazer.
                      const Text(
                        'Tarefas a Fazer',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Área que expande para ocupar o espaço vertical restante para a lista de tarefas a fazer.
                      Expanded(
                        flex: 1, // Dá flexibilidade para ocupar espaço
                        // ListView.builder cria itens de lista sob demanda.
                        child: ListView.builder(
                          // Número total de itens na lista (do Hive box).
                          itemCount: box.values.where((task) => !task.isCompleted).length, // Conta apenas tarefas não concluídas
                          // Constrói cada item da lista.
                          itemBuilder: (context, index) {
                            // Obtém a lista de tarefas não concluídas e pega o item pelo índice.
                            final task = box.values.where((task) => !task.isCompleted).toList()[index];
                            // ListTile é um widget conveniente para itens de lista.
                            return ListTile(
                              // Widget à esquerda (Checkbox para marcar como concluído).
                              leading: Checkbox(
                                value: task.isCompleted, // Estado de checked do checkbox.
                                onChanged: (_) => _toggleTask(task), // Chamado ao marcar/desmarcar.
                                activeColor: Colors.white, // Cor do checkbox quando marcado.
                                checkColor: Colors.blue, // Cor do 'check' dentro do checkbox.
                              ),
                              // O conteúdo principal do item da lista (o texto da tarefa).
                              title: Text(
                                task.title, // Exibe o título da tarefa.
                                style: TextStyle(
                                  // Adiciona ou remove a decoração de linha (riscado) com base no estado de conclusão.
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: Colors.white, // Cor do texto da tarefa.
                                ),
                              ),
                              // Widget à direita (botão de exclusão).
                              trailing: IconButton(
                                icon: const Icon(Icons.delete), // Ícone de lixeira.
                                onPressed: () => _removeTask(task), // Chamado ao pressionar o botão.
                                color: Colors.white, // Cor do ícone.
                              ),
                            );
                          },
                        ),
                      ),
                       // Espaço vertical entre as listas.
                      const SizedBox(height: 16),
                       // Título para as tarefas concluídas.
                      const Text(
                        'Tarefas Concluídas',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                       // Área que expande para ocupar o espaço vertical restante para a lista de tarefas concluídas.
                      Expanded(
                         flex: 1, // Dá flexibilidade para ocupar espaço
                        // ListView.builder cria itens de lista sob demanda.
                        child: ListView.builder(
                          // Número total de itens na lista (do Hive box).
                           itemCount: box.values.where((task) => task.isCompleted).length, // Conta apenas tarefas concluídas
                          // Constrói cada item da lista.
                          itemBuilder: (context, index) {
                            // Obtém a lista de tarefas concluídas e pega o item pelo índice.
                             final task = box.values.where((task) => task.isCompleted).toList()[index];
                            // ListTile é um widget conveniente para itens de lista.
                            return ListTile(
                              // Widget à esquerda (Checkbox para marcar como concluído).
                              leading: Checkbox(
                                value: task.isCompleted, // Estado de checked do checkbox.
                                onChanged: (_) => _toggleTask(task), // Chamado ao marcar/desmarcar.
                                activeColor: Colors.white, // Cor do checkbox quando marcado.
                                checkColor: Colors.blue, // Cor do 'check' dentro do checkbox.
                              ),
                              // O conteúdo principal do item da lista (o texto da tarefa).
                              title: Text(
                                task.title, // Exibe o título da tarefa.
                                style: TextStyle(
                                  // Adiciona ou remove a decoração de linha (riscado) com base no estado de conclusão.
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: Colors.white, // Cor do texto da tarefa.
                                ),
                              ),
                              // Widget à direita (botão de exclusão).
                              trailing: IconButton(
                                icon: const Icon(Icons.delete), // Ícone de lixeira.
                                onPressed: () => _removeTask(task), // Chamado ao pressionar o botão.
                                color: Colors.white, // Cor do ícone.
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Título do aplicativo posicionado na parte inferior da tela.
          // Visível apenas quando o teclado virtual está fechado.
          if (keyboardHeight == 0)
            const Positioned(
              // Posição horizontal: 0 da esquerda e 0 da direita + Center centraliza o texto.
              left: 0,
              right: 0,
              // Posição vertical: 40.0 pixels acima da base da tela. Ajuste para alinhar com a imagem.
              bottom: 40.0,
              // Centraliza o texto horizontalmente na área definida pelo Positioned.
              child: Center(
                child: Text(
                  'Kitty List', // O texto do título.
                  style: TextStyle(
                    fontSize: 32.0, // Tamanho da fonte mantido em 32
                    fontWeight: FontWeight.bold, // Peso da fonte (negrito).
                    color: Colors.black, // Cor do texto alterada para preto
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Método chamado quando o widget é removido da árvore de widgets.
  // Importante para liberar recursos.
  @override
  void dispose() {
    // Descarta o controlador de texto para liberar seus recursos.
    _textController.dispose();
    // Descarta o FocusNode para liberar seus recursos.
    _textFieldFocusNode.dispose();
    // Chama o dispose do superclasse.
    super.dispose();
  }
}
