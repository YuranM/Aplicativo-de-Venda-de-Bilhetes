import 'package:cloud_firestore/cloud_firestore.dart';

class IndividualTicket {
  final String id;
  final String purchaseId;
  final String userId;
  final String eventId;
  final String eventName;
  final String ticketType;
  final double price;
  final DateTime purchaseDate;
  bool isUsed;

  IndividualTicket({
    required this.id,
    required this.purchaseId,
    required this.userId,
    required this.eventId,
    required this.eventName,
    required this.ticketType,
    required this.price,
    required this.purchaseDate,
    this.isUsed = false,
  });

  factory IndividualTicket.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return IndividualTicket(
      id: doc.id,
      purchaseId: data['purchaseId'] ?? '',
      userId: data['userId'] ?? '',
      eventId: data['eventId'] ?? '',
      eventName: data['eventName'] ?? '',
      ticketType: data['ticketType'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      purchaseDate: (data['purchaseDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isUsed: data['isUsed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'purchaseId': purchaseId,
      'userId': userId,
      'eventId': eventId,
      'eventName': eventName,
      'ticketType': ticketType,
      'price': price,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'isUsed': isUsed,
    };
  }
}