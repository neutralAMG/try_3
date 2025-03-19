import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(EmergencyApp());
}

class EmergencyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Emergencias',
      theme: ThemeData(primarySwatch: Colors.red),
      home: EmergencyListScreen(),
    );
  }
}

class EmergencyListScreen extends StatefulWidget {
  @override
  _EmergencyListScreenState createState() => _EmergencyListScreenState();
}

class _EmergencyListScreenState extends State<EmergencyListScreen> {
  late Database _database;
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'emergenciess.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE events(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, title TEXT, description TEXT)",
        );
      },
      version: 1,
    );
    _loadEvents();
  }

  Future<void> _deleteEvent(int id) async {
    await _database.delete('events', where: 'id = ?', whereArgs: [id]);
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final List<Map<String, dynamic>> events = await _database.query('events');
    setState(() {
      _events = events;
    });
  }

  Future<void> _addEvent(String title, String description) async {
    await _database.insert('events', {
      'date': DateTime.now().toString(),
      'title': title,
      'description': description,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Emergencias')),
      body: ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(16),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _events[index]['title'],
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      Text(
                        _events[index]['date'].substring(0, 10),
                        style: TextStyle(fontSize: 18, color: Colors.black12),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    _events[index]['description'],
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Image.network(
                    "https://letsenhance.io/static/73136da51c245e80edc6ccfe44888a99/1015f/MainBefore.jpg",
                    fit: BoxFit.fill,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FloatingActionButton(
                        child: Icon(Icons.remove),
                        backgroundColor: Colors.red[400],
                        mini: true,
                        onPressed: () async {
                          _deleteEvent(_events[index]['id']);
                        },
                      ),
                      Text(
                        "",
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          String? title = await _showTextInputDialog(
            'Título del Evento',
            context,
          );
          if (title != null && title.isNotEmpty) {
            String? description = await _showTextInputDialog(
              'Descripción del Evento',
              context,
            );
            if (description != null && description.isNotEmpty) {
              _addEvent(title, description);
            }
          }
        },
      ),
    );
  }

  Future<String?> _showTextInputDialog(
    String hint,
    BuildContext context,
  ) async {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(hint),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: hint),
            ),
            actions: [
              TextButton(
                child: Text('Cancelar'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Guardar'),
                onPressed: () => Navigator.pop(context, controller.text),
              ),
            ],
          ),
    );
  }
}
