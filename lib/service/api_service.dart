import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  /// Busca dados de endereço na API ViaCEP
  Future<Map<String, dynamic>?> buscarEnderecoPorCep(String cep) async {
    // Remove caracteres não numéricos
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanCep.length != 8) {
      return null;
    }

    final url = 'https://viacep.com.br/ws/$cleanCep/json/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Verifica se a API retornou um erro
        if (data.containsKey('erro') && data['erro'] == true) {
          return null; // CEP inválido
        }

        return data;
      }
    } catch (e) {
      // Em caso de erro de rede ou parsing
      print('Erro ao buscar CEP: $e');
    }
    return null;
  }
}
