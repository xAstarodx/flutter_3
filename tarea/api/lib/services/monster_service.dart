import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/monster.dart';

class MonsterService {
  static const String _baseUrl = 'https://rickandmortyapi.com/api/character';

  static Future<List<Monster>> fetchMonsters() async {
    try {
      final url = Uri.parse(_baseUrl);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data['results'] is List) {
          return (data['results'] as List)
              .map((json) => Monster.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        throw Exception('La respuesta de la API no tuvo el formato esperado.');
      } else {
        throw Exception(
          'Error al obtener los monstruos: ${response.statusCode}',
        );
      }
    } on FormatException {
      throw Exception(
        'La respuesta no es un JSON válido (posiblemente XML/HTML).',
      );
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
