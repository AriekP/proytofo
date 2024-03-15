import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:todolist/todo_model.dart';

class Completo extends StatelessWidget {
    final Box<TodoModel> _todoBox = Hive.box<TodoModel>('todos');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Tasks'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: _todoBox.listenable(),
        builder: (context, Box<TodoModel> box, _) {
          final completedTasks = box.values.where((task) => task.isDone).toList();
          return ListView.builder(
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              final task = completedTasks[index];
              return ListTile(
                title: Text(
                  task.description,
                  style: TextStyle(
                    decoration: task.isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                subtitle: _buildCompletionSubtitle(task),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCompletionSubtitle(TodoModel task) {
    if (task.dueDateTime != null) {
      return Text(
        'Due Date and Time: ${DateFormat('yyyy-MM-dd HH:mm').format(task.dueDateTime!)}',
      );
    } else {
      return const Text('Due date not set');
    }
  }
}