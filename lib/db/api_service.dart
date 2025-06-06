import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiUrl = 'http://164.90.152.205:5000/auth/login';
  static const String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzZXNzaW9uSWQiOiJhMTM2NWNiNy1hMDllLTQxZDMtYTc0OS0zOTQ0OWY1YWU3ZTgiLCJ1c2VySWQiOiI3YmI3ZmRmMS0yMjU5LTQ0NWQtOGZjNC0xNmYyZDcyYzgyY2YiLCJ1c2VybmFtZSI6ImFkbWluIiwidHVpIjoiNDI4Y2FmZTYtYmM3NC00ZGE4LThmMDYtNDM5MDg2NjU3ZjFkIiwiaWF0IjoxNzQ5MjUzMjU3fQ.N_6n7TW7G2G93MhR4EBP-wMobjKWkziXEXOIFZvDN4I';

  static Future<List<Map<String, dynamic>>> fetchDados() async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erro ao buscar dados');
    }
  }

  static Future<void> enviarDado(Map<String, dynamic> dado) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(dado),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao enviar dado');
    }
  }
}
