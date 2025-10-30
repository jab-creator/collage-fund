import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  final String id;
  final String title;
  final String description;
  final double goalAmount;
  final double currentAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.goalAmount,
    required this.currentAmount,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory Campaign.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Campaign(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      goalAmount: (data['goalAmount'] ?? 0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'goalAmount': goalAmount,
      'currentAmount': currentAmount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  Campaign copyWith({
    String? id,
    String? title,
    String? description,
    double? goalAmount,
    double? currentAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Campaign(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      goalAmount: goalAmount ?? this.goalAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  double get progressPercentage => goalAmount > 0 ? (currentAmount / goalAmount) * 100 : 0;
}