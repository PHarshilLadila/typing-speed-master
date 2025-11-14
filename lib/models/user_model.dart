// class UserModel {
//   final String id;
//   final String email;
//   final String? fullName;
//   final String? avatarUrl;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;

//   UserModel({
//     required this.id,
//     required this.email,
//     this.fullName,
//     this.avatarUrl,
//     this.createdAt,
//     this.updatedAt,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: json['id'] ?? '',
//       email: json['email'] ?? '',
//       fullName: json['full_name'],
//       avatarUrl: json['avatar_url'],
//       createdAt:
//           json['created_at'] != null
//               ? DateTime.parse(json['created_at'])
//               : null,
//       updatedAt:
//           json['updated_at'] != null
//               ? DateTime.parse(json['updated_at'])
//               : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'email': email,
//       'full_name': fullName,
//       'avatar_url': avatarUrl,
//       'created_at': createdAt?.toIso8601String(),
//       'updated_at': updatedAt?.toIso8601String(),
//     };
//   }

//   UserModel copyWith({
//     String? id,
//     String? email,
//     String? fullName,
//     String? avatarUrl,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return UserModel(
//       id: id ?? this.id,
//       email: email ?? this.email,
//       fullName: fullName ?? this.fullName,
//       avatarUrl: avatarUrl ?? this.avatarUrl,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
// }

class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String level;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final int totalTests;
  final int totalWords;
  final double averageWpm;
  final double averageAccuracy;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
    this.level = 'Beginner',
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
    this.totalTests = 0,
    this.totalWords = 0,
    this.averageWpm = 0,
    this.averageAccuracy = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      level: json['level'] ?? 'Beginner',
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastActivityDate:
          json['last_activity_date'] != null
              ? DateTime.parse(json['last_activity_date'])
              : null,
      totalTests: json['total_tests'] ?? 0,
      totalWords: json['total_words'] ?? 0,
      averageWpm: (json['average_wpm'] ?? 0).toDouble(),
      averageAccuracy: (json['average_accuracy'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'level': level,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_activity_date': lastActivityDate?.toIso8601String(),
      'total_tests': totalTests,
      'total_words': totalWords,
      'average_wpm': averageWpm,
      'average_accuracy': averageAccuracy,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? level,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    int? totalTests,
    int? totalWords,
    double? averageWpm,
    double? averageAccuracy,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      totalTests: totalTests ?? this.totalTests,
      totalWords: totalWords ?? this.totalWords,
      averageWpm: averageWpm ?? this.averageWpm,
      averageAccuracy: averageAccuracy ?? this.averageAccuracy,
    );
  }
}
