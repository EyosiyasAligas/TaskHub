class Note {
  String id;
  String title;
  String? content;
  List<TodoItem>? todoItems;
  bool isPinned;
  String? createdBy;
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
    this.createdBy,
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
  })  : createdAt = createdAt ?? DateTime.now(),
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

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'],
      todoItems: map['todoItems'] != null
          ? (map['todoItems'] as List).map((item) => TodoItem.fromMap(item)).toList()
          : null,
      createdBy: map['createdBy'] ?? '',
      isPinned: map['isPinned'] ?? false,
      color: map['color'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      collaborators: List<String>.from(map['collaborators'] ?? []),
      reminder: map['reminder'] != null ? DateTime.parse(map['reminder']) : null,
      tags: List<String>.from(map['tags'] ?? []),
      isArchived: map['isArchived'] ?? false,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      isTodo: map['isTodo'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'todoItems': todoItems?.map((item) => item.toMap()).toList(),
      'createdBy': createdBy, // Store who created the note
      'isPinned': isPinned,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'collaborators': collaborators,
      'reminder': reminder?.toIso8601String(),
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
