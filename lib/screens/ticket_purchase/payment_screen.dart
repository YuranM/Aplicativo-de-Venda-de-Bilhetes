import 'package:flutter/material.dart';
import 'package:eventos_app_cliente/models/event.dart';
import 'package:eventos_app_cliente/services/event_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:eventos_app_cliente/screens/user_tickets/user_tickets_screen.dart'; // Para navegar após a compra

class PaymentScreen extends StatefulWidget {
  final Event event;
  final Map<String, int> selectedQuantities;
  final double totalPrice;

  const PaymentScreen({
    super.key,
    required this.event,
    required this.selectedQuantities,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final EventService _eventService = EventService();
  bool _isProcessing = false;

  Future<void> _confirmPurchase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Usuário não logado.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _eventService.processTicketPurchase(
        userId: user.uid,
        event: widget.event,
        selectedQuantities: widget.selectedQuantities,
        totalPrice: widget.totalPrice,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compra de bilhetes efetuada com sucesso!')),
      );


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserTicketsScreen()),
      );

    } catch (e) {
      print('Erro ao confirmar compra: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao finalizar compra: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Pagamento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evento: ${widget.event.name}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.event.date)}',
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 30),
            const Text(
              'Detalhes dos Bilhetes:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedQuantities.length,
                itemBuilder: (context, index) {
                  final type = widget.selectedQuantities.keys.elementAt(index);
                  final quantity = widget.selectedQuantities[type]!;
                  if (quantity == 0) return const SizedBox.shrink(); // Não mostra bilhetes com 0 quantidade

                  final priceOption = widget.event.priceOptions
                      .firstWhere((opt) => opt.type == type);
                  final subtotal = quantity * priceOption.price;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$type (${quantity}x)', style: const TextStyle(fontSize: 16)),
                        Text(NumberFormat.currency(locale: 'pt_MZ', symbol: 'MZN').format(subtotal)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total a Pagar:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  NumberFormat.currency(locale: 'pt_MZ', symbol: 'MZN').format(widget.totalPrice),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Número do Cartão (Simulado)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'MM/AA',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                    maxLength: 4,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: _isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _confirmPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Confirmar Pagamento',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}