class SubtaskModel {
  const SubtaskModel({
    required this.id,
    required this.taskId,
    required this.title,
    required this.isDone,
  });

  final String id;
  final String taskId;
  final String title;
  final bool isDone;

  factory SubtaskModel.fromJson(Map<String, dynamic> json, String id) {
    return SubtaskModel(
      id: id,
      taskId: json['taskId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'taskId': taskId,
    'title': title,
    'isDone': isDone,
  };

  SubtaskModel copyWith({String? title, bool? isDone}) {
    return SubtaskModel(
      id: id,
      taskId: taskId,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}