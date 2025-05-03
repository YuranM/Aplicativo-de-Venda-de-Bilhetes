import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:eventos_app_admin/models/event.dart'; // NOVO: Importar o modelo de Event
import 'dart:io'; // Para o File

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<Event>> getAdminEvents(String adminId) {
    return _firestore
        .collection('events')
        .where('adminId', isEqualTo: adminId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Event.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addEvent(Event event) async {
    await _firestore.collection('events').add(event.toMap());
  }

  Future<void> updateEvent(Event event) async {
    if (event.id.isEmpty) {
      throw Exception("ID do evento inválido para atualização.");
    }
    await _firestore.collection('events').doc(event.id).update(event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      final imageUrl = eventDoc.data()?['imageUrl'];
      if (imageUrl != null && imageUrl.startsWith('https://firebasestorage.googleapis.com')) {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
        print('Imagem do evento excluída do Storage.');
      }
    } catch (e) {
      print('Aviso: Não foi possível excluir a imagem do Storage para o evento $eventId: $e');
    }

    final individualTicketsSnapshot = await _firestore.collection('individual_tickets')
        .where('eventId', isEqualTo: eventId)
        .get();

    for (var doc in individualTicketsSnapshot.docs) {
      await _firestore.collection('individual_tickets').doc(doc.id).delete();
    }
    print('Bilhetes individuais do evento $eventId excluídos.');

    final purchasesSnapshot = await _firestore.collection('ticket_purchases')
        .where('eventId', isEqualTo: eventId)
        .get();

    for (var doc in purchasesSnapshot.docs) {
      await _firestore.collection('ticket_purchases').doc(doc.id).delete();
    }
    print('Registos de compra do evento $eventId excluídos.');

    await _firestore.collection('events').doc(eventId).delete();
  }

  //Upload de imagem para o Firebase Storage
  Future<String> uploadImage(File imageFile) async {
    try {
      final storageRef = _storage.ref();
      final String fileName = 'events/${DateTime.now().millisecondsSinceEpoch}-${imageFile.path.split('/').last}';
      final uploadTask = storageRef.child(fileName).putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      rethrow;
    }
  }
}