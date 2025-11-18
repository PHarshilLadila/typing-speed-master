class ActivityLog {
  final String? id;
  final String userId;
  final DateTime activityDate;
  final int testCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ActivityLog({
    this.id,
    required this.userId,
    required this.activityDate,
    required this.testCount,
    this.createdAt,
    this.updatedAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id']?.toString(),
      userId: json['user_id'] ?? '',
      activityDate: DateTime.parse(json['activity_date']),
      testCount: json['test_count'] ?? 0,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'activity_date': activityDate.toIso8601String().split('T')[0],
      'test_count': testCount,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
