import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventos_app_cliente/models/event.dart';

import '../models/individual_ticket.dart';
import '../models/ticket_purchase.dart'; // Importe o modelo de evento

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Event>> getEvents() {
    return _firestore.collection('events').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    });
  }

  Future<Event?> getEventById(String eventId) async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        return Event.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar evento por ID: $e');
      return null;
    }
  }

  Stream<List<Event>> searchEvents({
    String? query,
    DateTime? startDate,
    String? eventType,
    String? location,
  }) {
    Query eventsQuery = _firestore.collection('events');

    if (query != null && query.isNotEmpty) {
    }
    if (startDate != null) {
      eventsQuery =
          eventsQuery.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (eventType != null && eventType.isNotEmpty) {
      eventsQuery = eventsQuery.where('eventType', isEqualTo: eventType);
    }
    if (location != null && location.isNotEmpty) {
      eventsQuery = eventsQuery.where('location', isEqualTo: location);
    }

    return eventsQuery.snapshots().map((snapshot) {
      print('Documentos filtrados recebidos: ${snapshot.docs.length}');
      for (var doc in snapshot.docs) {
        print('Documento Filtrado ID: ${doc.id}, Dados: ${doc.data()}');
      }

      return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    });
  }

  Future<void> processTicketPurchase({
    required String userId,
    required Event event,
    required Map<String, int> selectedQuantities,
    required double totalPrice,
  }) async {
    return _firestore.runTransaction((transaction) async {
      final eventRef = _firestore.collection('events').doc(event.id);
      final eventSnapshot = await transaction.get(eventRef);

      if (!eventSnapshot.exists) {
        throw Exception("Evento não encontrado no banco de dados.");
      }

      final currentEventData = eventSnapshot.data() as Map<String, dynamic>;
      List<dynamic> currentPriceOptions = currentEventData['priceOptions'] as List<dynamic>;

      List<TicketItem> purchasedTicketItemsSummary = [];
      List<IndividualTicket> newIndividualTickets = [];

      for (var option in event.priceOptions) {
        final selectedQty = selectedQuantities[option.type] ?? 0;

        if (selectedQty > 0) {
          int optionIndex = currentPriceOptions.indexWhere(
                  (item) => item['type'] == option.type);

          if (optionIndex == -1) {
            throw Exception("Tipo de bilhete '${option.type}' não encontrado para este evento.");
          }

          final currentAvailableQuantity =
          (currentPriceOptions[optionIndex]['availableQuantity'] as num).toInt();

          if (currentAvailableQuantity < selectedQty) {
            throw Exception(
                "Quantidade insuficiente de bilhetes para o tipo '${option.type}'. Disponíveis: $currentAvailableQuantity");
          }

          currentPriceOptions[optionIndex]['availableQuantity'] =
              currentAvailableQuantity - selectedQty;

          purchasedTicketItemsSummary.add(
            TicketItem(
              type: option.type,
              quantity: selectedQty,
              pricePerUnit: option.price,
              subtotal: selectedQty * option.price,
            ),
          );

          for (int i = 0; i < selectedQty; i++) {
            final individualTicketRef = _firestore.collection('individual_tickets').doc();
            newIndividualTickets.add(
              IndividualTicket(
                id: individualTicketRef.id,
                purchaseId: '',
                userId: userId,
                eventId: event.id,
                eventName: event.name,
                ticketType: option.type,
                price: option.price,
                purchaseDate: DateTime.now(),
                isUsed: false,
              ),
            );
          }
        }
      }

      transaction.update(eventRef, {'priceOptions': currentPriceOptions});

      final purchaseRef = _firestore.collection('ticket_purchases').doc();
      final newPurchase = TicketPurchase(
        id: purchaseRef.id,
        userId: userId,
        eventId: event.id,
        eventName: event.name,
        purchaseDate: DateTime.now(),
        totalPrice: totalPrice,
        ticketItems: purchasedTicketItemsSummary,
        status: 'completed',
      );
      transaction.set(purchaseRef, newPurchase.toMap());

      for (var individualTicket in newIndividualTickets) {
        individualTicket = IndividualTicket(
          id: individualTicket.id,
          purchaseId: purchaseRef.id,
          userId: individualTicket.userId,
          eventId: individualTicket.eventId,
          eventName: individualTicket.eventName,
          ticketType: individualTicket.ticketType,
          price: individualTicket.price,
          purchaseDate: individualTicket.purchaseDate,
          isUsed: individualTicket.isUsed,
        );
        transaction.set(_firestore.collection('individual_tickets').doc(individualTicket.id), individualTicket.toMap());
      }

    }).catchError((error) {
      print('Erro na transação de compra: $error');
      throw error;
    });
  }

  Stream<List<IndividualTicket>> getUserIndividualTickets(String userId) {
    return _firestore
        .collection('individual_tickets')
        .where('userId', isEqualTo: userId)
        .orderBy('purchaseDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => IndividualTicket.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<TicketPurchase>> getUserTicketPurchases(String userId) {
    return _firestore
        .collection('ticket_purchases')
        .where('userId', isEqualTo: userId)
        .orderBy('purchaseDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TicketPurchase.fromFirestore(doc))
          .toList();
    });
  }
}