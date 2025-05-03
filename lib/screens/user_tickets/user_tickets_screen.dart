import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventos_app_cliente/services/event_service.dart';
import 'package:eventos_app_cliente/models/individual_ticket.dart'; // NOVO: Importar o modelo de bilhete individual
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserTicketsScreen extends StatelessWidget {
  const UserTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meus Bilhetes')),
        body: const Center(child: Text('Por favor, faça login para ver seus bilhetes.')),
      );
    }

    final EventService _eventService = EventService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Bilhetes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<IndividualTicket>>(
        stream: _eventService.getUserIndividualTickets(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Erro ao carregar bilhetes individuais: ${snapshot.error}');
            return Center(child: Text('Erro ao carregar bilhetes: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Você ainda não comprou nenhum bilhete individual.'));
          }

          final individualTickets = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: individualTickets.length,
            itemBuilder: (context, index) {
              final ticket = individualTickets[index];
              final qrCodeContent = ticket.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.eventName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tipo de Bilhete: ${ticket.ticketType}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Preço: ${NumberFormat.currency(locale: 'pt_MZ', symbol: 'MZN').format(ticket.price)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Comprado em: ${DateFormat('dd/MM/yyyy HH:mm').format(ticket.purchaseDate)}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ticket.isUsed ? 'Status: Usado' : 'Status: Ativo',
                        style: TextStyle(
                          fontSize: 14,
                          color: ticket.isUsed ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 20),
                      Center(
                        child: QrImageView(
                          data: qrCodeContent,
                          version: QrVersions.auto,
                          size: 200.0,
                          gapless: false,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'ID do Bilhete: ${ticket.id}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}