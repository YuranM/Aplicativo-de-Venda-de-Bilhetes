import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventos_app_admin/screens/auth/admin_login_screen.dart'; // Para redirecionar no logout
import 'package:eventos_app_admin/models/event.dart'; // Para o modelo Event
import 'package:eventos_app_admin/services/event_service.dart';

import '../event_management/verifyTicket.dart'; // Para o serviço de eventos

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EventService _eventService = EventService();
  User? _currentUser;
  String? _adminName;

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
  }

  Future<void> _loadAdminInfo() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      final userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        setState(() {
          _adminName = userDoc.data()?['email'] ?? 'Administrador';
        });
      }
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const AdminLoginScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bem-vindo, ${_adminName ?? '...'}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Text(
              'Estatísticas de bilhetes por evento:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<List<Event>>(
                stream: _eventService.getAdminEvents(_currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar eventos: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nenhum evento para exibir estatísticas.'));
                  }

                  final events = snapshot.data!;

                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return FutureBuilder<Map<String, int>>(
                        future: _getTicketStatsForEvent(event.id),
                        builder: (context, statsSnapshot) {
                          if (statsSnapshot.connectionState == ConnectionState.waiting) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(event.name),
                                subtitle: const Text('Carregando estatísticas...'),
                                trailing: const CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }
                          if (statsSnapshot.hasError) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(event.name),
                                subtitle: Text('Erro ao carregar estatísticas: ${statsSnapshot.error}'),
                              ),
                            );
                          }

                          final stats = statsSnapshot.data ?? {'totalSold': 0, 'totalUsed': 0, 'totalAvailable': 0};
                          final totalSold = stats['totalSold']!;
                          final totalUsed = stats['totalUsed']!;
                          final totalAvailable = stats['totalAvailable']!;
                          final remainingTickets = totalAvailable - totalUsed;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const Divider(),
                                  _buildStatRow('Bilhetes Disponíveis para Venda:', totalAvailable),
                                  _buildStatRow('Bilhetes Vendidos:', totalSold),
                                  _buildStatRow('Bilhetes Verificados (Usados):', totalUsed),
                                  _buildStatRow('Bilhetes Restantes (para uso):', remainingTickets),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => TicketScannerScreen(
                                              eventId: event.id,
                                              eventName: event.name,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.qr_code_scanner),
                                      label: const Text('Verificar Bilhetes'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.grey)),
          Text(value.toString(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<Map<String, int>> _getTicketStatsForEvent(String eventId) async {

    final eventDoc = await _firestore.collection('events').doc(eventId).get();
    int totalAvailable = 0;
    if (eventDoc.exists) {
      final eventData = eventDoc.data() as Map<String, dynamic>;
      final List<dynamic> priceOptions = eventData['priceOptions'] ?? [];
      for (var option in priceOptions) {
        totalAvailable += (option['availableQuantity'] as num).toInt();
      }
    }
    final soldTicketsSnapshot = await _firestore
        .collection('individual_tickets')
        .where('eventId', isEqualTo: eventId)
        .get();
    final int totalSold = soldTicketsSnapshot.docs.length;

    final usedTicketsSnapshot = await _firestore
        .collection('individual_tickets')
        .where('eventId', isEqualTo: eventId)
        .where('isUsed', isEqualTo: true)
        .get();
    final int totalUsed = usedTicketsSnapshot.docs.length;

    return {
      'totalSold': totalSold,
      'totalUsed': totalUsed,
      'totalAvailable': totalAvailable,
    };
  }
}
