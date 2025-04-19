import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DebugSpotifyScreen extends StatefulWidget {
  const DebugSpotifyScreen({super.key});

  @override
  State<DebugSpotifyScreen> createState() => _DebugSpotifyScreenState();
}

class _DebugSpotifyScreenState extends State<DebugSpotifyScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _suggestions = [];
  List<Map<String, String>> _selectedSongs = [];
  String? _accessToken;
  bool _isLoading = false;

  final String clientId = '43019c4f95e94a1daf3372b6b14baf52';
  final String clientSecret = '68dd1d3c4240455ea02f5aa88b6ece8b';

  @override
  void initState() {
    super.initState();
    _getAccessToken();
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _controller.text.trim();
    if (query.length >= 2 && _accessToken != null) {
      _searchSpotifySongs(query);
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  Future<void> _getAccessToken() async {
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _accessToken = data['access_token'];
        print('Conexión a Spotify: Exitosa.');
      });
    } else {
      print('Error obteniendo token: ${response.body}');
    }
  }

  Future<void> _searchSpotifySongs(String query) async {
    setState(() => _isLoading = true);
    final url = 'https://api.spotify.com/v1/search?q=$query&type=track&limit=8';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tracks = data['tracks']['items'] as List;

      setState(() {
        _suggestions = tracks.map<Map<String, String>>((track) {
          final name = track['name'];
          final artist = (track['artists'] as List)[0]['name'];
          final image = track['album']['images'][0]['url'];
          return {'title': name, 'artist': artist, 'imageUrl': image};
        }).toList();
      });
    } else {
      print('Error al buscar canciones: ${response.body}');
    }
    setState(() => _isLoading = false);
  }

  void _selectSong(Map<String, String> song) {
    setState(() {
      if (_selectedSongs.length == 3) {
        _selectedSongs.removeAt(0);
      }
      _selectedSongs.add(song);
      _controller.clear();
      _suggestions = [];
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscador Spotify')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Escribí una canción...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Expanded(
                child: Column(
                  children: [
                    if (_suggestions.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: _suggestions.length,
                          itemBuilder: (context, index) {
                            final song = _suggestions[index];
                            return ListTile(
                              leading: Image.network(song['imageUrl']!, width: 50, height: 50, fit: BoxFit.cover),
                              title: Text(song['title']!),
                              subtitle: Text(song['artist']!),
                              onTap: () => _selectSong(song),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (_selectedSongs.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Seleccionadas:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _selectedSongs.length,
                            itemBuilder: (context, index) {
                              final song = _selectedSongs[index];
                              return ListTile(
                                leading: Image.network(song['imageUrl']!, width: 50, height: 50, fit: BoxFit.cover),
                                title: Text(song['title']!),
                                subtitle: Text(song['artist']!),
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
