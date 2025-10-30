import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentMethod { stripe, interac }

enum ContributionStatus { pending, completed, failed, refunded }

class Contribution {
  final String id;
  final String campaignId;
  final String? contributorName;
  final double amount;
  final bool isAnonymous;
  final PaymentMethod paymentMethod;
  final ContributionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? paymentIntentId; // For Stripe
  final String? transactionId; // For Interac or other payment methods
  final String? message; // Optional message from contributor

  Contribution({
    required this.id,
    required this.campaignId,
    this.contributorName,
    required this.amount,
    required this.isAnonymous,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.paymentIntentId,
    this.transactionId,
    this.message,
  });

  factory Contribution.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Contribution(
      id: doc.id,
      campaignId: data['campaignId'] ?? '',
      contributorName: data['contributorName'],
      amount: (data['amount'] ?? 0).toDouble(),
      isAnonymous: data['isAnonymous'] ?? false,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${data['paymentMethod']}',
        orElse: () => PaymentMethod.stripe,
      ),
      status: ContributionStatus.values.firstWhere(
        (e) => e.toString() == 'ContributionStatus.${data['status']}',
        orElse: () => ContributionStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      paymentIntentId: data['paymentIntentId'],
      transactionId: data['transactionId'],
      message: data['message'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'campaignId': campaignId,
      'contributorName': contributorName,
      'amount': amount,
      'isAnonymous': isAnonymous,
      'paymentMethod': paymentMethod.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'paymentIntentId': paymentIntentId,
      'transactionId': transactionId,
      'message': message,
    };
  }

  Contribution copyWith({
    String? id,
    String? campaignId,
    String? contributorName,
    double? amount,
    bool? isAnonymous,
    PaymentMethod? paymentMethod,
    ContributionStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? paymentIntentId,
    String? transactionId,
    String? message,
  }) {
    return Contribution(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      contributorName: contributorName ?? this.contributorName,
      amount: amount ?? this.amount,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      transactionId: transactionId ?? this.transactionId,
      message: message ?? this.message,
    );
  }

  String get displayName => isAnonymous ? 'Anonymous' : (contributorName ?? 'Anonymous');
}