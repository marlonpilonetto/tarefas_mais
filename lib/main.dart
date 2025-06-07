import 'package:flutter/material.dart';
import 'db/db_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('SQLite no Flutter')),
      body: Column(
        children: [
          TextField(controller: _controller),
          ElevatedButton(
            onPressed: () async {
              await DBHelper.inserirPessoa(_controller.text);
            },
            child: Text('Salvar no SQLite'),
          ),
          Expanded(
            child: FutureBuilder(
              future: DBHelper.listarPessoas(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final pessoas = snapshot.data as List<Map<String, dynamic>>;
                return ListView.builder(
                  itemCount: pessoas.length,
                  itemBuilder: (_, i) =>
                      ListTile(title: Text(pessoas[i]['nome'])),
                );
              },
            ),
          )
        ],
      ),
    ),
  );
}
