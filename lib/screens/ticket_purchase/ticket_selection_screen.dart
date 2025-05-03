import 'package:eventos_app_cliente/screens/ticket_purchase/payment_screen.dart'; // Importação correta
import 'package:flutter/material.dart';
import 'package:eventos_app_cliente/models/event.dart';
import 'package:intl/intl.dart'; // Para formatar moeda

class TicketSelectionScreen extends StatefulWidget {
  final Event event;

  const TicketSelectionScreen({super.key, required this.event});

  @override
  State<TicketSelectionScreen> createState() => _TicketSelectionScreenState();
}

class _TicketSelectionScreenState extends State<TicketSelectionScreen> {
  Map<String, int> _selectedQuantities = {};
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    for (var option in widget.event.priceOptions) {
      _selectedQuantities[option.type] = 0;
    }
    _calculateTotalPrice();
  }

  void _updateQuantity(String ticketType, int delta) {
    setState(() {
      int currentQuantity = _selectedQuantities[ticketType] ?? 0;
      int newQuantity = currentQuantity + delta;

      PriceOption option = widget.event.priceOptions
          .firstWhere((opt) => opt.type == ticketType);

      if (newQuantity >= 0 && newQuantity <= option.availableQuantity) {
        _selectedQuantities[ticketType] = newQuantity;
        _calculateTotalPrice();
      }
    });
  }

  void _calculateTotalPrice() {
    double total = 0.0;
    for (var option in widget.event.priceOptions) {
      total += (_selectedQuantities[option.type] ?? 0) * option.price;
    }
    setState(() {
      _totalPrice = total;
    });
  }

  void _proceedToPayment() {
    final selectedTicketsRaw = _selectedQuantities.entries
        .where((entry) => entry.value > 0)
        .toList();

    if (selectedTicketsRaw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione pelo menos um bilhete.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          event: widget.event,
          selectedQuantities: _selectedQuantities,
          totalPrice: _totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Bilhetes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(widget.event.date),
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  widget.event.location,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const Divider(height: 30),
                const Text(
                  'Escolha seus bilhetes:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.event.priceOptions.length,
              itemBuilder: (context, index) {
                final option = widget.event.priceOptions[index];
                final currentQuantity = _selectedQuantities[option.type] ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.type,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              NumberFormat.currency(
                                  locale: 'pt_MZ', symbol: 'MZN').format(
                                  option.price),
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.green),
                            ),
                            Text(
                              'Disponíveis: ${option.availableQuantity}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: currentQuantity > 0
                                  ? () => _updateQuantity(option.type, -1)
                                  : null,
                            ),
                            Text(
                              '$currentQuantity',
                              style: const TextStyle(fontSize: 18),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: currentQuantity <
                                  option.availableQuantity
                                  ? () => _updateQuantity(option.type, 1)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      NumberFormat
                          .currency(locale: 'pt_MZ', symbol: 'MZN')
                          .format(_totalPrice),
                      style: const TextStyle(fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _totalPrice > 0 ? _proceedToPayment : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Continuar para o Pagamento',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}