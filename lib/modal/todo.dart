class Todo {
  final String id;
  late String title;
  bool isCompleted = false;
  bool isEditing;

  Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.isEditing = false,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };
}
