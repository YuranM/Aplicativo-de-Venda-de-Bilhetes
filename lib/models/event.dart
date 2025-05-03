import 'package:cloud_firestore/cloud_firestore.dart';

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
  final DateTime date;
  final String location;
  final String address;
  final String imageUrl;
  final String? videoUrl;
  final String eventType;
  final List<PriceOption> priceOptions;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.location,
    required this.address,
    required this.imageUrl,
    this.videoUrl,
    required this.eventType,
    required this.priceOptions,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    print('Dados do Firestore para ${data['name']}: $data');
    print('Tipo de data[\'priceOptions\']: ${data['priceOptions']?.runtimeType}');


    List<PriceOption> loadedPriceOptions = [];
    if (data['priceOptions'] is List) {
      loadedPriceOptions = (data['priceOptions'] as List)
          .map((item) {
        if (item is Map<String, dynamic>) {
          return PriceOption.fromMap(item);
        }
        return null;
      })
          .whereType<PriceOption>()
          .toList();
    } else {
      print('AVISO: priceOptions não é uma lista ou está ausente. Tipo: ${data['priceOptions']?.runtimeType}');
    }


    return Event(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      address: data['address'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      videoUrl: data['videoUrl'],
      eventType: data['eventType'] ?? '',
      priceOptions: loadedPriceOptions,
    );
  }
}