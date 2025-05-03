import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Importar o scanner
import 'package:cloud_functions/cloud_functions.dart'; // Para Cloud Functions
import 'package:firebase_auth/firebase_auth.dart'; // Para pegar o adminId

class TicketScannerScreen extends StatefulWidget {
  final String eventId; // O ID do evento que o admin está a gerenciar
  final String eventName;

  const TicketScannerScreen({super.key, required this.eventId, required this.eventName});

  @override
  State<TicketScannerScreen> createState() => _TicketScannerScreenState();
}

class _TicketScannerScreenState extends State<TicketScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessingScan = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _processBarcode(Barcode barcode) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('ERRO FLUTTER: currentUser é null no scanner antes de chamar a CF!');
      _showResultDialog('Erro de Autenticação', 'Não foi possível verificar seu status de login. Por favor, faça login novamente.', Colors.red);
      setState(() {
        _isProcessingScan = false;
        cameraController.start();
      });
      return;
    }

    String? ticketId = barcode.rawValue;
    String eventIdFromWidget = widget.eventId;

    if (ticketId == null || ticketId.isEmpty) {
      _showResultDialog('Erro', 'Código de barras inválido ou vazio lido.', Colors.red);
      setState(() {
        _isProcessingScan = false;
        cameraController.start();
      });
      return;
    }

    if (eventIdFromWidget.isEmpty) { // eventId nunca deveria ser null, mas pode ser vazio
      _showResultDialog('Erro', 'ID do evento não fornecido. Por favor, tente novamente.', Colors.red);
      setState(() {
        _isProcessingScan = false;
        cameraController.start();
      });
      return;
    }

    if (_isProcessingScan) return;

    setState(() {
      _isProcessingScan = true;
      cameraController.stop();
    });


    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('verifyTicket');
      final result = await callable.call({
        'ticketId': ticketId,
        'eventId': eventIdFromWidget,
      });

      final data = result.data as Map<String, dynamic>;
      String status = data['status'];
      String message = data['message'];
      String? ticketType = data['ticketType'];

      if (status == 'valid') {
        _showResultDialog(
          'Bilhete Válido!',
          '${message}\nTipo: ${ticketType ?? 'N/A'}',
          Colors.green,
        );
      } else if (status == 'already_used') {
        _showResultDialog(
          'Bilhete Já Utilizado',
          message,
          Colors.orange,
        );
      } else {
        _showResultDialog(
          'Bilhete Inválido',
          message,
          Colors.red,
        );
      }
    } on FirebaseFunctionsException catch (e) {
      print('FLUTTER ERRO na Verificação da CF: ${e.code} - ${e.message}');
      _showResultDialog(
        'Erro na Verificação',
        '${e.message}',
        Colors.red,
      );
    } catch (e) {
      print('FLUTTER ERRO Desconhecido: ${e.toString()}');
      _showResultDialog(
        'Erro Desconhecido',
        'Ocorreu um erro: ${e.toString()}',
        Colors.red,
      );
    } finally {
      if (mounted && _isProcessingScan) {
        setState(() {
          _isProcessingScan = false;
          cameraController.start();
        });
      }
    }
  }

  void _showResultDialog(String title, String content, Color color) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: color)),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verificar Bilhetes - ${widget.eventName}')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  _processBarcode(barcodes.first);
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                _isProcessingScan ? 'Processando...' : 'Aponte a câmera para o QR Code',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
