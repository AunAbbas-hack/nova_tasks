import 'package:cloud_firestore/cloud_firestore.dart';
import 'subtask_model.dart';

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String priority;
  final String category;
  final DateTime? completedAt;
  final String? recurrenceRule;
  final String? parentTaskId;
  final bool hasAttachment;
  final List<SubtaskModel> subtasks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.priority,
    required this.category,
    this.completedAt,
    this.recurrenceRule,
    this.parentTaskId,
    this.hasAttachment = false,
    this.subtasks = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // ---------------- FIRESTORE FROM ----------------
  factory TaskModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    final data = doc.data() ?? {};

    return TaskModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      time: data['time'] ?? '',
      priority: data['priority'] ?? 'medium',
      category: data['category'] ?? 'general',
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      recurrenceRule: data['recurrenceRule'],
      parentTaskId: data['parentTaskId'],
      hasAttachment: data['hasAttachment'] ?? false,
      subtasks: (data['subtasks'] as List<dynamic>? ?? [])
          .map((e) => SubtaskModel.fromJson(e, e['id']))
          .toList(),
      createdAt:
      (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
      (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ---------------- FIRESTORE TO ----------------
  Map<String, dynamic> toFirestore() {
    final map = {
      'userId': userId,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'time': time,
      'priority': priority,
      'category': category,
      'recurrenceRule': recurrenceRule,
      'parentTaskId': parentTaskId,
      'hasAttachment': hasAttachment,
      'subtasks': [
        for (final s in subtasks) {'id': s.id, ...s.toJson()}
      ],
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };

    // remove null fields
    if (completedAt != null) {
      map['completedAt'] = Timestamp.fromDate(completedAt!);
    }

    return map;
  }

  // ---------------- COPYWITH (FULL + SAFE) ----------------
  TaskModel copyWith({
    String? title,
    String? description,
    DateTime? date,
    String? time,
    String? priority,
    String? category,
    DateTime? completedAt,
    String? recurrenceRule,
    String? parentTaskId,
    bool? hasAttachment,
    List<SubtaskModel>? subtasks,
  }) {
    return TaskModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      completedAt: completedAt ?? this.completedAt,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      hasAttachment: hasAttachment ?? this.hasAttachment,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
