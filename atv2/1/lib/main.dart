import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Eventos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: EventRegistryScreen(),
    );
  }
}

class Event {
  final String date;
  final String time;
  final String description;

  Event({
    required this.date,
    required this.time,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'description': description,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      date: json['date'],
      time: json['time'],
      description: json['description'],
    );
  }
}

class EventRegistryScreen extends StatefulWidget {
  @override
  _EventRegistryScreenState createState() => _EventRegistryScreenState();
}

class _EventRegistryScreenState extends State<EventRegistryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString('events');
      
      if (eventsJson != null) {
        final List<dynamic> jsonData = json.decode(eventsJson);
        
        setState(() {
          _events = jsonData.map((eventJson) => Event.fromJson(eventJson)).toList();
        });
      }
    } catch (e) {
      print('Erro ao carregar eventos: $e');
    }
  }

  Future<void> _saveEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final List<Map<String, dynamic>> jsonData = 
          _events.map((event) => event.toJson()).toList();
      
      await prefs.setString('events', json.encode(jsonData));
    } catch (e) {
      print('Erro ao salvar eventos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar evento: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addEvent() {
    if (_formKey.currentState!.validate()) {
      final newEvent = Event(
        date: "${_selectedDate.day.toString().padLeft(2, '0')}/"
              "${_selectedDate.month.toString().padLeft(2, '0')}/"
              "${_selectedDate.year}",
        time: "${_selectedTime.hour.toString().padLeft(2, '0')}:"
              "${_selectedTime.minute.toString().padLeft(2, '0')}",
        description: _descriptionController.text,
      );

      setState(() {
        _events.add(newEvent);
      });

      _saveEvents();
      _descriptionController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Evento salvo com sucesso!')),
      );
    }
  }

  void _removeEvent(int index) {
    setState(() {
      _events.removeAt(index);
    });
    _saveEvents();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Evento removido!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Eventos'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Novo Evento',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Data',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            "${_selectedDate.day.toString().padLeft(2, '0')}/"
                            "${_selectedDate.month.toString().padLeft(2, '0')}/"
                            "${_selectedDate.year}",
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      InkWell(
                        onTap: () => _selectTime(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Hora',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.access_time),
                          ),
                          child: Text(
                            "${_selectedTime.hour.toString().padLeft(2, '0')}:"
                            "${_selectedTime.minute.toString().padLeft(2, '0')}",
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Descrição do Evento',
                          border: OutlineInputBorder(),
                          hintText: 'Digite a descrição do evento...',
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira uma descrição';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: _addEvent,
                        child: Text('Adicionar Evento'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 20),

            Expanded(
              child: Card(
                elevation: 4,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Eventos Registrados (${_events.length})',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Expanded(
                      child: _events.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_note,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Nenhum evento registrado',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _events.length,
                              itemBuilder: (context, index) {
                                final event = _events[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Icon(Icons.event),
                                      backgroundColor: Colors.blue,
                                    ),
                                    title: Text(
                                      event.description,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      '${event.date} às ${event.time}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeEvent(index),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}