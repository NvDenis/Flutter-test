import 'package:flutter/material.dart';
import 'package:my_todo_list_app/modal/todo.dart';
import 'package:my_todo_list_app/widgets/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:confirm_dialog/confirm_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Todo> todoList = [];

  TextEditingController taskController = TextEditingController();

  Future<void> _loadTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedList = prefs.getStringList('todoList');

    if (savedList != null) {
      setState(() {
        todoList
            .addAll(savedList.map((json) => Todo.fromJson(jsonDecode(json))));
      });
    }
  }

  Future<void> _saveTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedList =
        todoList.map((todo) => jsonEncode(todo.toJson())).toList();
    await prefs.setStringList('todoList', encodedList);
  }

  void _handleAddTask() {
    String taskTitle = taskController.text;
    if (taskTitle.isNotEmpty) {
      Todo newTodo = Todo(
          id: DateTime.now().toString(), title: taskTitle, isCompleted: false);
      setState(() {
        todoList.add(newTodo);
      });
      taskController.clear();
      FocusScope.of(context).requestFocus(taskFocusNode);
      _saveTodoList();
    }
  }

  void _handleDeleteTask(String id) {
    if (id.isNotEmpty) {
      setState(() {
        todoList.removeWhere((element) => element.id == id);
      });
      _saveTodoList();
    }
  }

  void _handleTextTap(String id) {
    setState(() {
      Todo tappedTodo = todoList.firstWhere((element) => element.id == id);
      tappedTodo.isCompleted = !tappedTodo.isCompleted;
    });
    _saveTodoList();
  }

  void _handleToggleEditing(Todo todo) {
    FocusScope.of(context).requestFocus(taskFocusNode);

    setState(() {
      isEditing = !isEditing;
      dataEdit = todo;
      taskController.text = todo.title;

      for (var element in todoList) {
        if (element.id == todo.id) {
          element.isEditing = !todo.isEditing;
        } else {
          element.isEditing = false;
        }
      }
    });
  }

  bool isEditing = false;
  Todo? dataEdit;
  FocusNode taskFocusNode = FocusNode();

  void _handleEditTask() {
    setState(() {
      String newTitle = taskController.text;

      Todo editedTodo =
          todoList.firstWhere((element) => element.id == dataEdit?.id);

      editedTodo.title = newTitle;
      editedTodo.isEditing = false;
      isEditing = !isEditing;
      taskController.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTodoList();
  }

  void _handleReorder() {
    setState(() {
      todoList = todoList.reversed.toList();
    });
    _saveTodoList();
  }

  void _handleDeleteAllTasks(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete all tasks?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed != null && confirmed) {
        setState(() {
          todoList.clear();
        });
        _saveTodoList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Todo List2')),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.all(20),
                // decoration: const BoxDecoration(color: Colors.black),
                width: 800,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        focusNode: taskFocusNode,
                        controller: taskController,
                        onSubmitted: (value) {
                          isEditing ? _handleEditTask() : _handleAddTask();
                        },
                        decoration: InputDecoration(
                          labelText: taskController.text.isEmpty
                              ? 'Add your task here ...'
                              : '',
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isEditing ? _handleEditTask : _handleAddTask,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 25),
                        ),
                        child: Text(isEditing ? 'EDIT TASK' : 'ADD TASK'),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: SizedBox(
                  width: 800,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: _handleReorder,
                        icon: const Icon(Icons.sort),
                        splashRadius: 24,
                      ),
                      const SizedBox(width: 10),
                      Builder(
                        builder: (context) => IconButton(
                          onPressed: () => _handleDeleteAllTasks(context),
                          splashRadius: 24,
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  width: 800,
                  child: ListView(
                    children: todoList
                        .map((todo) => Task(
                              todo: todo,
                              handleDeleteTask: _handleDeleteTask,
                              handleTextTap: _handleTextTap,
                              handleToggleEditing: _handleToggleEditing,
                              isEditing: isEditing,
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
