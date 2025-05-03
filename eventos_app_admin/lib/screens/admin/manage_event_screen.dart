// Copiar o conteúdo COMPLETO do manage_event_screen.dart do projeto cliente para aqui.
// Verifique as importações.

import 'package:flutter/material.dart';
import 'package:eventos_app_admin/models/event.dart'; // NOVO: Mudar import
import 'package:eventos_app_admin/services/event_service.dart'; // NOVO: Mudar import
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ManageEventScreen extends StatefulWidget {
  final Event? event;
  final String adminId;

  const ManageEventScreen({super.key, this.event, required this.adminId});

  @override
  State<ManageEventScreen> createState() => _ManageEventScreenState();
}

class _ManageEventScreenState extends State<ManageEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _imageUrl;

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _videoUrlController;
  DateTime? _selectedDate;
  String? _selectedEventType;

  List<Map<String, dynamic>> _priceOptions = [];

  bool _isLoading = false;

  final List<String> _eventTypes = [
    'Música',
    'Teatro',
    'Desporto',
    'Feira',
    'Conferência',
    'Outro'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event?.name ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    _locationController = TextEditingController(text: widget.event?.location ?? '');
    _videoUrlController = TextEditingController(text: widget.event?.videoUrl ?? '');
    _selectedDate = widget.event?.date;
    _selectedEventType = widget.event?.eventType;
    _imageUrl = widget.event?.imageUrl;

    if (widget.event != null && widget.event!.priceOptions.isNotEmpty) {
      _priceOptions = widget.event!.priceOptions.map((po) => po.toMap()).toList();
    } else {
      _priceOptions.add({'type': '', 'price': 0.0, 'availableQuantity': 0});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        _imageUrl = null;
      }
    });
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione a data do evento.')),
      );
      return;
    }

    if (_imageFile == null && _imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma imagem para o evento.')),
      );
      return;
    }

    if (_priceOptions.any((option) => option['type'].isEmpty || option['price'] <= 0 || option['availableQuantity'] <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todas as opções de bilhete corretamente.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? finalImageUrl = _imageUrl;
      if (_imageFile != null) {
        finalImageUrl = await _eventService.uploadImage(_imageFile!);
      }

      if (finalImageUrl == null) {
        throw Exception('Não foi possível obter a URL da imagem.');
      }

      final List<PriceOption> parsedPriceOptions = _priceOptions
          .map((map) => PriceOption(
        type: map['type'] as String,
        price: (map['price'] as num).toDouble(),
        availableQuantity: (map['availableQuantity'] as num).toInt(),
      ))
          .toList();

      Event eventToSave = Event(
        id: widget.event?.id ?? '',
        name: _nameController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        date: _selectedDate!,
        imageUrl: finalImageUrl,
        eventType: _selectedEventType ?? 'Outro',
        videoUrl: _videoUrlController.text.isNotEmpty ? _videoUrlController.text : null,
        adminId: widget.adminId,
        priceOptions: parsedPriceOptions,
      );

      if (widget.event == null) {
        await _eventService.addEvent(eventToSave);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento criado com sucesso!')),
        );
      } else {
        await _eventService.updateEvent(eventToSave);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento atualizado com sucesso!')),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      print('Erro ao salvar evento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar evento: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Criar Novo Evento' : 'Editar Evento'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Evento'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do evento.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição do evento.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Local'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o local do evento.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tipo de Evento'),
                value: _selectedEventType,
                items: _eventTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEventType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione o tipo de evento.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data e Hora',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Selecionar Data e Hora'
                            : DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate!),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Selecionar Imagem'),
              ),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.file(_imageFile!, height: 100, fit: BoxFit.cover),
                )
              else if (_imageUrl != null && _imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.network(_imageUrl!, height: 100, fit: BoxFit.cover),
                ),
              TextFormField(
                controller: _videoUrlController,
                decoration: const InputDecoration(labelText: 'URL do Vídeo (Opcional)'),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 20),
              const Text('Opções de Bilhete:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._priceOptions.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> option = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          initialValue: option['type'],
                          decoration: const InputDecoration(labelText: 'Tipo (Ex: Geral, VIP)'),
                          onChanged: (value) => option['type'] = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Insira o tipo';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: option['price']?.toString(),
                          decoration: const InputDecoration(labelText: 'Preço'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => option['price'] = double.tryParse(value) ?? 0.0,
                          validator: (value) {
                            if (double.tryParse(value ?? '') == null || double.parse(value!) <= 0) {
                              return 'Preço inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: option['availableQuantity']?.toString(),
                          decoration: const InputDecoration(labelText: 'Qtd. Disp.'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => option['availableQuantity'] = int.tryParse(value) ?? 0,
                          validator: (value) {
                            if (int.tryParse(value ?? '') == null || int.parse(value!) <= 0) {
                              return 'Qtd. inválida';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            if (_priceOptions.length > 1) {
                              _priceOptions.removeAt(index);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pelo menos uma opção de bilhete é necessária.')),
                              );
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _priceOptions.add({'type': '', 'price': 0.0, 'availableQuantity': 0});
                    });
                  },
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Adicionar Opção de Bilhete'),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.event == null ? 'Criar Evento' : 'Atualizar Evento',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}