import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _senhaVisivel = false;

  void _toggleSenhaVisibility() {
    setState(() {
      _senhaVisivel = !_senhaVisivel;
    });
  }

  void _fazerLogin() {
    final String usuario = _usuarioController.text.trim();
    final String senha = _senhaController.text.trim();

    if (usuario == 'admin' && senha == 'admin') {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário ou senha inválidos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usuarioController,
              decoration: const InputDecoration(
                labelText: 'Usuário',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _senhaController,
              obscureText: !_senhaVisivel,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _senhaVisivel
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: _toggleSenhaVisibility,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Entrar'),
              onPressed: _fazerLogin,
            ),
          ],
        ),
      ),
    );
  }
}