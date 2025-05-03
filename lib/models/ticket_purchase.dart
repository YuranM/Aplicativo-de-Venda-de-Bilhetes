import 'package:cloud_firestore/cloud_firestore.dart';

class TicketItem {
  final String type;
  final int quantity;
  final double pricePerUnit;
  final double subtotal;

  TicketItem({
    required this.type,
    required this.quantity,
    required this.pricePerUnit,
    required this.subtotal,
  });

  factory TicketItem.fromMap(Map<String, dynamic> map) {
    return TicketItem(
      type: map['type'] as String,
      quantity: (map['quantity'] as num).toInt(),
      pricePerUnit: (map['price_per_unit'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'quantity': quantity,
      'price_per_unit': pricePerUnit,
      'subtotal': subtotal,
    };
  }
}

class TicketPurchase {
  final String id;
  final String userId;
  final String eventId;
  final String eventName;
  final DateTime purchaseDate;
  final double totalPrice;
  final List<TicketItem> ticketItems;
  final String status;

  TicketPurchase({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.eventName,
    required this.purchaseDate,
    required this.totalPrice,
    required this.ticketItems,
    this.status = 'completed',
  });

  factory TicketPurchase.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TicketPurchase(
      id: doc.id,
      userId: data['userId'] ?? '',
      eventId: data['eventId'] ?? '',
      eventName: data['eventName'] ?? '',
      purchaseDate: (data['purchaseDate'] as Timestamp).toDate(),
      totalPrice: (data['totalPrice'] as num).toDouble(),
      ticketItems: (data['ticketItems'] as List)
          .map((itemMap) => TicketItem.fromMap(itemMap as Map<String, dynamic>))
          .toList(),
      status: data['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'eventId': eventId,
      'eventName': eventName,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'totalPrice': totalPrice,
      'ticketItems': ticketItems.map((item) => item.toMap()).toList(),
      'status': status,
    };
  }
}