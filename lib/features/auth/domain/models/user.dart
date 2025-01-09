class User {
  final String id;
  final String email;
  final List<String>? top3canciones;
  final String? tragoFavorito;

  const User({
    required this.id,
    required this.email,
    this.top3canciones,
    this.tragoFavorito,
  });

  // Método para convertir desde JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      top3canciones: json['top3canciones'] != null
          ? List<String>.from(json['top3canciones'])
          : null,
      tragoFavorito: json['tragoFavorito'] as String?,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'top3canciones': top3canciones,
      'tragoFavorito': tragoFavorito,
    };
  }
}
