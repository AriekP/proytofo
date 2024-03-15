import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolist/todo_model.dart';
import 'delete_confirmation_dialog.dart';
class TodoListTile extends StatefulWidget {
   final TodoModel todo;
  final int index;
  final Function(int) onDelete;
  final Function(int, String, bool, DateTime?) onUpdate;

  const TodoListTile({
    Key? key,
    required this.todo,
    required this.index,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _TodoListTileState createState() => _TodoListTileState();
}

class _TodoListTileState extends State<TodoListTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              title: Text(
                widget.todo.description,
                style: TextStyle(
                  decoration: widget.todo.isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: _buildSubtitle(widget.todo),
              value: widget.todo.isDone,
              onChanged: (value) {
                setState(() {
                  widget.todo.isDone = value ?? false;
                  if (widget.todo.isDone) {
                    _selectDateTime();
                  }
                  widget.onUpdate(
                    widget.index,
                    widget.todo.description,
                    widget.todo.isDone,
                    widget.todo.dueDateTime,
                  );
                });
              },
            ),
          ],
        ),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                _showUpdateDialog(context);
              },
              child: Icon(
                Icons.edit,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                _showDeleteConfirmationDialog(context);
              },
              child: Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                _selectDateTime();
              },
              child: Icon(
                Icons.calendar_today,
                color: Colors.green,
              ),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                _selectTime();
              },
              child: Icon(
                Icons.access_time,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle(TodoModel task) {
    if (task.dueDateTime != null) {
      return Text(
        'Due Date and Time: ${DateFormat('yyyy-MM-dd HH:mm').format(task.dueDateTime!)}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      return const Text('Due date not set');
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: widget.todo.dueDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (pickedDateTime != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          widget.todo.dueDateTime ?? DateTime.now(),
        ),
      );

      if (pickedTime != null) {
        setState(() {
          widget.todo.dueDateTime = DateTime(
            pickedDateTime.year,
            pickedDateTime.month,
            pickedDateTime.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        widget.todo.dueDateTime ?? DateTime.now(),
      ),
    );

    if (pickedTime != null) {
      setState(() {
        widget.todo.dueDateTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void _showUpdateDialog(BuildContext context) async {
    String newDescription = widget.todo.description;

    final updatedTodo = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newDescription = value;
                },
                controller: TextEditingController(text: newDescription),
              ),
              Checkbox(
                value: widget.todo.isDone,
                onChanged: (value) {
                  setState(() {
                    widget.todo.isDone = value ?? false;
                    if (widget.todo.isDone) {
                      _selectDateTime();
                    }
                  });
                },
              ),
              Text(
                'Due Date and Time: ${widget.todo.dueDateTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(widget.todo.dueDateTime!) : 'Not set'}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  {'description': newDescription, 'isDone': widget.todo.isDone, 'dueDateTime': widget.todo.dueDateTime},
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (updatedTodo != null) {
      widget.onUpdate(
        widget.index,
        updatedTodo['description'],
        updatedTodo['isDone'],
        updatedTodo['dueDateTime'],
      );
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          onCancel: () {
            Navigator.of(context).pop();
          },
          onDelete: () {
            widget.onDelete(widget.index);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}