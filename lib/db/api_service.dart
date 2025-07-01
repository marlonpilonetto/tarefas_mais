import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String apiUrl = 'http://164.90.152.205:5000';
  static const String endpointLogin = '/auth/login';
  static const String endpointTarefas = '/tarefas';

  /// Faz login, salva token localmente e retorna o token
  static Future<String> login(String usuario, String senha) async {
    final response = await http.post(
      Uri.parse('$apiUrl$endpointLogin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usuario,
        'password': senha,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['token'] != null) {
      final token = data['token'];

      // Salvar token localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return token;
    } else {
      throw Exception('Erro no login: ${response.body}');
    }
  }

  /// Recupera o token salvo localmente
  static Future<String?> getTokenSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Busca dados usando o token salvo
  static Future<List<Map<String, dynamic>>> buscarTarefas() async {
    final token = await getTokenSalvo();
    if (token == null) throw Exception('Token não encontrado. Faça login.');

    final response = await http.get(
      Uri.parse('$apiUrl$endpointTarefas'),
      headers: {
        'Content-Type': 'application/json',
        'access-token': token,
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erro ao buscar dados: ${response.body}');
    }
  }

  /// Envia tarefa usando o token salvo
  static Future<void> criarTarefa(Map<String, dynamic> dado) async {
    final token = await getTokenSalvo();
    if (token == null) throw Exception('Token não encontrado. Faça login.');

    final response = await http.post(
      Uri.parse('$apiUrl$endpointTarefas'),
      headers: {
        'access-token': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(dado),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao enviar tarefa: ${response.body}');
    }
  }

  /// Atualiza uma tarefa usando o token salvo
  static Future<void> atualizarTarefa(dynamic id, Map<String, dynamic> dado) async {
    final token = await getTokenSalvo();
    if (token == null) throw Exception('Token não encontrado. Faça login.');

    final response = await http.patch(
      Uri.parse('$apiUrl$endpointTarefas/$id'),
      headers: {
        'access-token': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(dado),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar tarefa: ${response.body}');
    }
  }

  /// Exclui uma tarefa usando o token salvo
  static Future<void> excluirTarefa(dynamic id) async {
    final token = await getTokenSalvo();
    if (token == null) throw Exception('Token não encontrado. Faça login.');

    final response = await http.delete(
      Uri.parse('$apiUrl$endpointTarefas/$id'),
      headers: {
        'access-token': token,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao excluir tarefa: ${response.body}');
    }
  }
}
