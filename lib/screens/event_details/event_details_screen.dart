import 'package:flutter/material.dart';
import 'package:eventos_app_cliente/models/event.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir links externos (mapas, vídeos)
import 'package:video_player/video_player.dart'; // Para reproduzir vídeos
import 'package:chewie/chewie.dart';

import '../ticket_purchase/ticket_selection_screen.dart'; // Para um player de vídeo mais robusto

class EventDetailsScreen extends StatefulWidget {
  final Event event;
  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.event.videoUrl != null && widget.event.videoUrl!.isNotEmpty) {
      _initializeVideoPlayer();
    }
  }

  Future<void> _initializeVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.event.videoUrl!));
    await _videoPlayerController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      showOptions: false,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Não foi possível abrir: $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
              child: Image.network(
                event.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 100),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Vídeo do evento (se houver)
            if (event.videoUrl != null && event.videoUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trailer/Destaque',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _chewieController != null &&
                        _chewieController!.videoPlayerController.value.isInitialized
                        ? AspectRatio(
                      aspectRatio: _chewieController!.aspectRatio ?? 16 / 9,
                      child: Chewie(
                        controller: _chewieController!,
                      ),
                    )
                        : Container(
                      height: 200,
                      color: Colors.black,
                      child: const Center(
                          child: CircularProgressIndicator(color: Colors.white)),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

            // Detalhes do evento
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.description,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const Divider(height: 30),
                  _buildDetailRow(Icons.calendar_today,
                      DateFormat('dd/MM/yyyy HH:mm').format(event.date)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      _launchUrl('https://www.google.com/maps/search/?api=1&query=${event.address}');
                    },
                    child: _buildDetailRow(Icons.location_on, '${event.location}, ${event.address}',
                        isClickable: true),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(Icons.category, event.eventType),
                  const Divider(height: 30),

                  const Text(
                    'Opções de Bilhetes:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (event.priceOptions.isEmpty)
                    const Text('Nenhuma opção de bilhete disponível no momento.')
                  else
                    ...event.priceOptions.map((option) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${option.type}:',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${NumberFormat.currency(locale: 'pt_MZ', symbol: 'MZN').format(option.price)} (${option.availableQuantity} disponíveis)',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TicketSelectionScreen(event: event),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'Comprar Bilhetes',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {bool isClickable = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blueAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isClickable ? Colors.blue : Colors.black87,
              decoration: isClickable ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}