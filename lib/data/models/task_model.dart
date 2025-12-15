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
  final String? recurrenceRule;
  final String? parentTaskId;
  final bool hasAttachment;
  final List<SubtaskModel> subtasks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final List<DateTime> completedDates; // For recurring tasks - tracks which specific dates are completed
  final DateTime? dueAt;
  final bool reminder24Sent;
  final bool reminder60Sent;
  final bool reminder30Sent;
  final bool reminder10Sent;
  final bool reminder5Sent;
  final bool overdueSent;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.priority,
    required this.category,
    this.recurrenceRule,
    this.parentTaskId,
    this.hasAttachment = false,
    this.subtasks = const [],
    this.completedAt,
      this.completedDates = const [],
    required this.createdAt,
    required this.updatedAt,
    this.dueAt,
    this.reminder24Sent = false,
    this.reminder60Sent = false,
    this.reminder30Sent = false,
    this.reminder10Sent = false,
    this.reminder5Sent = false,
    this.overdueSent = false,
  });

  // ---------------- FIRESTORE FROM ----------------
  factory TaskModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      SnapshotOptions? _,
      ) {
    final data = doc.data() ?? {};

    final dateTs = data['date'] as Timestamp?;
    final baseDate = dateTs?.toDate() ?? DateTime.now();

    //  Try reading dueAt, otherwise fallback to date-only
    DateTime? dueAt;
    final dueAtRaw = data['dueAt'];
    if (dueAtRaw is Timestamp) {
      dueAt = dueAtRaw.toDate();
    } else {
      // fallback: at least date set, time 00:00
      dueAt = DateTime(baseDate.year, baseDate.month, baseDate.day);
    }

    return TaskModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      date: baseDate,
      time: data['time'] as String? ?? '',
      priority: data['priority'] as String? ?? 'medium',
      category: data['category'] as String? ?? 'general',
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      completedDates: (data['completedDates'] as List<dynamic>? ?? [])
          .map((e) => (e as Timestamp).toDate())
          .toList(),
      recurrenceRule: data['recurrenceRule'] as String?,
      parentTaskId: data['parentTaskId'] as String?,
      hasAttachment: data['hasAttachment'] as bool? ?? false,
      subtasks: (data['subtasks'] as List<dynamic>? ?? [])
          .map((e) => SubtaskModel.fromJson(e, e['id']))
          .toList(),
      createdAt:
      (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
      (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),

      // NEW
      dueAt: dueAt,
      reminder24Sent: data['reminder24Sent'] as bool? ?? false,
      reminder60Sent: data['reminder60Sent'] as bool? ?? false,
      reminder30Sent: data['reminder30Sent'] as bool? ?? false,
      reminder10Sent: data['reminder10Sent'] as bool? ?? false,
      reminder5Sent: data['reminder5Sent'] as bool? ?? false,
      overdueSent: data['overdueSent'] as bool? ?? false,
    );
  }

  // ---------------- FIRESTORE TO ----------------
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
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
        for (final s in subtasks) {'id': s.id, ...s.toJson()},
      ],
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'dueAt': Timestamp.fromDate(
        dueAt ?? date, // fallback: at least date le lo
      ),
      'reminder24Sent': reminder24Sent,
      'reminder60Sent': reminder60Sent,
      'reminder30Sent': reminder30Sent,
      'reminder10Sent': reminder10Sent,
      'reminder5Sent': reminder5Sent,
      'overdueSent': overdueSent,
    };

    if (completedAt != null) {
      map['completedAt'] = Timestamp.fromDate(completedAt!);
    }
    
    if (completedDates.isNotEmpty) {
      map['completedDates'] = completedDates.map((d) => Timestamp.fromDate(d)).toList();
    }

    return map;
  }

  TaskModel copyWith({
    String? title,
    String? description,
    DateTime? date,
    String? time,
    String? priority,
    String? category,
    Object? completedAt=_notProvided,
    List<DateTime>? completedDates,
    String? recurrenceRule,
    String? parentTaskId,
    bool? hasAttachment,
    List<SubtaskModel>? subtasks,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueAt,
    bool? reminder24Sent,
    bool? reminder60Sent,
    bool? reminder30Sent,
    bool? reminder10Sent,
    bool? reminder5Sent,
    bool? overdueSent,
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
      completedAt: completedAt == _notProvided ? this.completedAt : (completedAt as DateTime?),
      completedDates: completedDates ?? this.completedDates,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      hasAttachment: hasAttachment ?? this.hasAttachment,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      dueAt: dueAt ?? this.dueAt,
      reminder24Sent: reminder24Sent ?? this.reminder24Sent,
      reminder60Sent: reminder60Sent ?? this.reminder60Sent,
      reminder30Sent: reminder30Sent ?? this.reminder30Sent,
      reminder10Sent: reminder10Sent ?? this.reminder10Sent,
      reminder5Sent: reminder5Sent ?? this.reminder5Sent,
      overdueSent: overdueSent ?? this.overdueSent,
    );
  }
}
const Object _notProvided=Object();
