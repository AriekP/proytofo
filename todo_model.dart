import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel extends HiveObject {
  @HiveField(0)
  late String description;

  @HiveField(1)
  late bool isDone;

  @HiveField(2)
  DateTime? dueDateTime;

  TodoModel({
    required this.description,
    this.isDone = false,
    this.dueDateTime,
  });
}