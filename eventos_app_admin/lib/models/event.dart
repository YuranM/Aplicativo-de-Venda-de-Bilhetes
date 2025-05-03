import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PriceOption {
  final String type;
  final double price;
  final int availableQuantity;

  PriceOption({
    required this.type,
    required this.price,
    required this.availableQuantity,
  });

  factory PriceOption.fromMap(Map<String, dynamic> map) {
    return PriceOption(
      type: map['type'] as String,
      price: (map['price'] as num).toDouble(),
      availableQuantity: (map['availableQuantity'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'price': price,
      'availableQuantity': availableQuantity,
    };
  }
}

class Event {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime date;
  final String imageUrl;
  final String eventType;
  final String? videoUrl;
  final List<PriceOption> priceOptions;
  final String adminId;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.imageUrl,
    required this.eventType,
    this.videoUrl,
    required this.priceOptions,
    required this.adminId,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<PriceOption> loadedPriceOptions = [];
    if (data['priceOptions'] is List) {
      loadedPriceOptions = (data['priceOptions'] as List)
          .map((optionMap) =>
          PriceOption.fromMap(optionMap as Map<String, dynamic>))
          .toList();
    }

    return Event(
      id: doc.id,
      name: data['name'] ?? 'Nome do Evento Desconhecido',
      description: data['description'] ?? 'Sem descrição.',
      location: data['location'] ?? 'Local Desconhecido',
      date: (data['date'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
      eventType: data['eventType'] ?? 'Normal',
      videoUrl: data['videoUrl'],
      priceOptions: loadedPriceOptions,
      adminId: data['adminId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'eventType': eventType,
      'videoUrl': videoUrl,
      'priceOptions': priceOptions.map((e) => e.toMap()).toList(),
      'adminId': adminId,
    };
  }

  String get formattedDate => DateFormat('dd/MM/yyyy HH:mm').format(date);
}