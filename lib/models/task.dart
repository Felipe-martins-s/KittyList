import 'package:hive/hive.dart';

part 'task.g.dart';

// Classe que representa uma tarefa no app
@HiveType(typeId: 0)
class Task extends HiveObject {
  // Título da tarefa
  @HiveField(0)
  String title;

  // Se a tarefa foi concluída ou não
  @HiveField(1)
  bool isCompleted;

  // Construtor da tarefa
  Task({
    required this.title,
    this.isCompleted = false,
  });
} 