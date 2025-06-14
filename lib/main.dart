import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Inicialização obrigatória para desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const TarefasMaisApp());
}

class TarefasMaisApp extends StatelessWidget {
  const TarefasMaisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tarefas+',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/dashboard': (context) => const TarefasDashboard(),
      },
    );
  }
}
