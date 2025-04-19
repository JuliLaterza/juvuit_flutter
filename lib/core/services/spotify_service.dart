import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyService {
  static const String _clientId = '43019c4f95e94a1daf3372b6b14baf52';
  static const String _clientSecret = '68dd1d3c4240455ea02f5aa88b6ece8b';
  static String? _accessToken;

  /// Obtiene un nuevo token (o reutiliza el existente si ya existe)
  static Future<void> _ensureAccessToken() async {
    if (_accessToken != null) return;

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$_clientId:$_clientSecret'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
    } else {
      throw Exception('Error obteniendo token: ${response.body}');
    }
  }

  /// Busca canciones en Spotify
  static Future<List<Map<String, String>>> searchSongs(String query) async {
    await _ensureAccessToken();

    final url = 'https://api.spotify.com/v1/search?q=$query&type=track&limit=8';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tracks = data['tracks']['items'] as List;

      return tracks.map<Map<String, String>>((track) {
        final name = track['name'];
        final artist = (track['artists'] as List)[0]['name'];
        final image = track['album']['images'][0]['url'];
        return {
          'title': name,
          'artist': artist,
          'imageUrl': image,
        };
      }).toList();
    } else {
      throw Exception('Error al buscar canciones: ${response.body}');
    }
  }

  /// Borra el token si querés reiniciar el servicio (opcional)
  static void resetToken() {
    _accessToken = null;
  }
}
