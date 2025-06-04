// Importando as bibliotecas necessárias
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/task.dart';

// Função que inicia o app
Future<void> main() async {
  // Configurando o banco de dados local
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasksBox');

  runApp(const MyApp());
}

// Classe principal do app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitty List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoListScreen(),
    );
  }
}

// Tela que mostra a lista de tarefas
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

// Estado da tela de tarefas
class _TodoListScreenState extends State<TodoListScreen> {
  // Banco de dados local
  final _tasksBox = Hive.box<Task>('tasksBox');
  // Campo para digitar nova tarefa
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();

  // Variáveis para editar tarefa
  Task? _editingTask;
  final TextEditingController _editController = TextEditingController();
  final FocusNode _editFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  // Função que adiciona uma tarefa nova
  void _addTask(String title) {
    if (title.isNotEmpty) {
      _tasksBox.add(Task(title: title));
      _textController.clear();
      if (_textFieldFocusNode.hasFocus) {
        _textFieldFocusNode.requestFocus();
      }
    }
  }

  // Função que marca/desmarca tarefa como feita
  void _toggleTask(Task task) {
    if (_textFieldFocusNode.hasFocus) {
      _textFieldFocusNode.unfocus();
    }
    task.isCompleted = !task.isCompleted;
    task.save();
    setState(() {});
  }

  // Função que remove uma tarefa
  void _removeTask(Task task) {
    if (_textFieldFocusNode.hasFocus) {
      _textFieldFocusNode.unfocus();
    }
    final int index = _tasksBox.values.toList().indexOf(task);
    if (index != -1) {
      _tasksBox.deleteAt(index);
    }
    setState(() {});
  }

  // Mostra popup de confirmação antes de excluir
  void _confirmDeleteTask(Task task) {
    if (_textFieldFocusNode.hasFocus) {
      _textFieldFocusNode.unfocus();
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir a tarefa "${task.title}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir'),
              onPressed: () {
                _removeTask(task);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Inicia a edição de uma tarefa
  void _startEditing(Task task) {
    if (_textFieldFocusNode.hasFocus) {
      _textFieldFocusNode.unfocus();
    }
    setState(() {
      _editingTask = task;
      _editController.text = task.title;
    });
    Future.delayed(Duration(milliseconds: 50), () {
      _editFocusNode.requestFocus();
    });
  }

  // Salva a tarefa após edição
  void _saveEditing(Task task, String newTitle) {
     if (newTitle.isNotEmpty) {
      task.title = newTitle;
      task.save();
     }
    _stopEditing();
  }

  // Finaliza a edição
  void _stopEditing() {
     setState(() {
      _editingTask = null;
      _editController.clear();
     });
  }

  @override
  Widget build(BuildContext context) {
    // Pega a altura do teclado
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // Pega a altura da barra de status
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    // Espaço reservado na parte de baixo
    const double reservedBottomSpace = 150.0;

    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo
          Positioned.fill(
            child: Image.asset(
              'assets/images/BackgroudBanco.png',
              fit: BoxFit.cover,
            ),
          ),
          // Lista de tarefas
          ValueListenableBuilder(
            valueListenable: _tasksBox.listenable(),
            builder: (context, box, _) {
              return GestureDetector(
                onTap: () {
                  // Remove o foco quando tocar em qualquer lugar fora do input
                  if (_textFieldFocusNode.hasFocus) {
                    _textFieldFocusNode.unfocus();
                  }
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    top: statusBarHeight + 8.0,
                    left: 16.0,
                    right: 16.0,
                    bottom: reservedBottomSpace,
                  ),
                  // Área cinza semi-transparente
                  child: Container(
                    color: Colors.grey.withAlpha((255 * 0.0).round()),
                    child: Column(
                      children: [
                        // Campo para adicionar tarefas
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                focusNode: _textFieldFocusNode,
                                decoration: const InputDecoration(
                                  hintText: 'Adicionar nova tarefa',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (value) {
                                  _addTask(value);
                                  // Mantém o foco após adicionar via teclado
                                  _textFieldFocusNode.requestFocus();
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                _addTask(_textController.text);
                                // Mantém o foco após adicionar via botão
                                _textFieldFocusNode.requestFocus();
                              },
                              child: const Text('Adicionar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Título da lista de tarefas não feitas
                        const Text(
                          'Tarefas a Fazer',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Lista de tarefas não feitas
                        Expanded(
                          flex: 1,
                          child: ListView.builder(
                            itemCount: box.values.where((task) => !task.isCompleted).length,
                            itemBuilder: (context, index) {
                              final task = box.values.where((task) => !task.isCompleted).toList()[index];
                              final bool isEditing = task == _editingTask;

                              return ListTile(
                                onTap: () => _startEditing(task),
                                leading: Checkbox(
                                  value: task.isCompleted,
                                  onChanged: (_) => _toggleTask(task),
                                  activeColor: Colors.white,
                                  checkColor: Colors.blue,
                                ),
                                title: isEditing
                                    ? TextField(
                                        controller: _editController,
                                        focusNode: _editFocusNode,
                                        autofocus: true,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        ),
                                        onSubmitted: (newValue) => _saveEditing(task, newValue),
                                        onTapOutside: (event) => _saveEditing(task, _editController.text),
                                      )
                                    : Text(
                                        task.title,
                                        style: TextStyle(
                                          decoration: task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          color: Colors.white,
                                        ),
                                      ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _confirmDeleteTask(task),
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Título da lista de tarefas feitas
                        const Text(
                          'Tarefas Concluídas',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Lista de tarefas feitas
                        Expanded(
                          flex: 1,
                          child: ListView.builder(
                            itemCount: box.values.where((task) => task.isCompleted).length,
                            itemBuilder: (context, index) {
                              final task = box.values.where((task) => task.isCompleted).toList()[index];
                              final bool isEditing = task == _editingTask;

                              return ListTile(
                                onTap: () => _startEditing(task),
                                leading: Checkbox(
                                  value: task.isCompleted,
                                  onChanged: (_) => _toggleTask(task),
                                  activeColor: Colors.white,
                                  checkColor: Colors.blue,
                                ),
                                title: isEditing
                                    ? TextField(
                                        controller: _editController,
                                        focusNode: _editFocusNode,
                                        autofocus: true,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        ),
                                        onSubmitted: (newValue) => _saveEditing(task, newValue),
                                        onTapOutside: (event) => _saveEditing(task, _editController.text),
                                      )
                                    : Text(
                                        task.title,
                                        style: TextStyle(
                                          decoration: task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          color: Colors.white,
                                        ),
                                      ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _confirmDeleteTask(task),
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Título do app na parte de baixo
          if (keyboardHeight == 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 21.0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xff8e68e6),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.5 * 255).round()),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Kitty List',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.normal,
                      color: Color(0xffeab7ef),
                      fontFamily: 'Upheaval',
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Limpa os controladores e nodes de foco
    _textController.dispose();
    _textFieldFocusNode.dispose();
    _editController.dispose();
    _editFocusNode.dispose();
    super.dispose();
  }
}
