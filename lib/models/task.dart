import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  Task({
    required this.title,
    this.isCompleted = false,
  });

  void delete() {}

  void save() {}
} 