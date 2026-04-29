import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  UserModel({
    required this.name,
    required this.email,
    required this.joinedDate,
    this.phone,
    this.dob,
    this.totalAssessments,
    this.lastAssessmentDate,
    this.lastRiskLevel,
    this.createdAt,
    this.updatedAt,
  });

  final String name;
  final String email;
  final String joinedDate;
  final String? phone;
  final String? dob;

  final int? totalAssessments;
  final String? lastAssessmentDate;
  final String? lastRiskLevel;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'joinedDate': joinedDate,
    'phone': phone,
    'dob': dob,
    if (totalAssessments != null) 'totalAssessments': totalAssessments,
    if (lastAssessmentDate != null) 'lastAssessmentDate': lastAssessmentDate,
    if (lastRiskLevel != null) 'lastRiskLevel': lastRiskLevel,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'email': email,
    'joinedDate': joinedDate,
    'phone': phone,
    'dob': dob,
    if (totalAssessments != null) 'totalAssessments': totalAssessments,
    if (lastAssessmentDate != null) 'lastAssessmentDate': lastAssessmentDate,
    if (lastRiskLevel != null) 'lastRiskLevel': lastRiskLevel,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    joinedDate: json['joinedDate'] as String? ?? '',
    phone: json['phone'] as String?,
    dob: json['dob'] as String?,
    totalAssessments: json['totalAssessments'] as int?,
    lastAssessmentDate: json['lastAssessmentDate'] as String?,
    lastRiskLevel: json['lastRiskLevel'] as String?,
    createdAt: json['createdAt'] is Timestamp
        ? (json['createdAt'] as Timestamp).toDate()
        : json['createdAt'] is String
        ? DateTime.tryParse(json['createdAt'] as String)
        : null,
    updatedAt: json['updatedAt'] is Timestamp
        ? (json['updatedAt'] as Timestamp).toDate()
        : json['updatedAt'] is String
        ? DateTime.tryParse(json['updatedAt'] as String)
        : null,
  );

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? dob,
    int? totalAssessments,
    String? lastAssessmentDate,
    String? lastRiskLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      joinedDate: joinedDate,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      totalAssessments: totalAssessments ?? this.totalAssessments,
      lastAssessmentDate: lastAssessmentDate ?? this.lastAssessmentDate,
      lastRiskLevel: lastRiskLevel ?? this.lastRiskLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
