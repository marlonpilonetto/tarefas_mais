import 'package:flutter/material.dart';
import 'db/db_helper.dart';

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  final TextEditingController _nomeController = TextEditingController();

  Future<void> _salvarUsuario() async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome do usuário')),
      );
      return;
    }
    await DBHelper.inserirPessoa(nome);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
    );
    Navigator.of(context).pop(); // Fecha a tela de cadastro
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Usuário')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do usuário',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Cadastrar'),
                onPressed: _salvarUsuario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}