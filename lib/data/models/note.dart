class Note {
  String id;
  String title;
  String? content;
  List<TodoItem>? todoItems;
  bool isPinned;
  String createdBy;
  String? color;
  DateTime createdAt;
  DateTime updatedAt;
  List<String> collaborators;
  DateTime? reminder;
  List<String> tags;
  bool isArchived;
  List<String>? imageUrls;
  bool isTodo;

  Note({
    required this.id,
    required this.title,
    this.content,
    this.todoItems,
    required this.createdBy,
    this.isPinned = false,
    this.color,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.collaborators = const [],
    this.reminder,
    this.tags = const [],
    this.isArchived = false,
    this.imageUrls,
    this.isTodo = false,
  })
      : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();


  void updateContent(String newContent) {
    content = newContent;
    updatedAt = DateTime.now();
  }

  void updateTodoItems(List<TodoItem> newTodoItems) {
    todoItems = newTodoItems;
    updatedAt = DateTime.now();
  }

  void togglePin() {
    isPinned = !isPinned;
  }

  void toggleArchive() {
    isArchived = !isArchived;
  }

  void toggleTodo() {
    isTodo = !isTodo;
    if (!isTodo) {
      // Clear todo items if switching back to a regular note
      todoItems = null;
    } else {
      // Clear content if switching to todo mode
      content = null;
    }
  }

  void addCollaborator(String userId) {
    if (!collaborators.contains(userId)) {
      collaborators.add(userId);
    }
  }

  void removeCollaborator(String userId) {
    collaborators.remove(userId);
  }

  factory Note.fromMap(Map<String, dynamic> data) {

    //if any data item is null then it will be replaced by default value
    return Note(
      id: data['id'] as String,
      title: data['title'] as String,
      content: data['content'] as String?,
      todoItems: data['todoItems'] != null
          ? (data['todoItems'] as List<dynamic>)
          .map((item) => TodoItem.fromMap(Map<String, dynamic>.from(item)))
          .toList()
          : null,
      createdBy: data['createdBy'] as String,
      isPinned: data['isPinned'] as bool? ?? false,
      color: data['color'] as String? ?? '',
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
      collaborators: data['collaborators'] != null ? List<String>.from(data['collaborators']) : [],
      reminder: data['reminder'] != null ? DateTime.parse(data['reminder']) : null,
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
      isArchived: data['isArchived'] as bool? ?? false,
      imageUrls: data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : null,
      isTodo: data['isTodo'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'todoItems': todoItems != null ? todoItems?.map((item) => item.toMap()).toList() : null,
      'createdBy': createdBy,
      'isPinned': isPinned,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'collaborators': collaborators,
      'reminder': reminder,
      'tags': tags,
      'isArchived': isArchived,
      'imageUrls': imageUrls,
      'isTodo': isTodo,
    };
  }

}
class TodoItem {
  String task;
  bool isCompleted;

  TodoItem({required this.task, this.isCompleted = false});

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      task: map['task'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  // Convert TodoItem to a Map (for Firebase integration)
  Map<String, dynamic> toMap() {
    return {
      'task': task,
      'isCompleted': isCompleted,
    };
  }
}
