import 'package:flutter/material.dart';

class Task extends StatefulWidget {
  Task({
    super.key,
    required this.todo,
    required this.handleDeleteTask,
    required this.handleTextTap,
    required this.handleToggleEditing,
    required this.isEditing,
  });

  var todo;
  final Function handleDeleteTask;
  final Function handleTextTap;
  final Function handleToggleEditing;
  bool isEditing;

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 800,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 8,
                  child: GestureDetector(
                    onTap: () {
                      widget.handleTextTap(widget.todo.id);
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        widget.todo.title,
                        style: TextStyle(
                            decoration: widget.todo.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    hoverColor: Colors.transparent,
                    onPressed: () {
                      widget.handleToggleEditing(widget.todo);
                    },
                    icon: Icon(
                      widget.todo.isEditing ? Icons.check : Icons.edit,
                      color: Colors.orange,
                    ),
                    splashRadius: 24,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    splashRadius: 24,
                    hoverColor: Colors.transparent,
                    onPressed: () {


                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Delete Task'),
                                      content: const Text(
                                          'Are you sure you want to delete this task?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            widget.handleDeleteTask(widget.todo.id);
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  });
                    },
                    icon: const Icon(
                      Icons.delete_outline_sharp,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              thickness: 1,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
