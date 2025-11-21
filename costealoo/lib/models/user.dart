class User {
  final int id;
  final String nombre;
  final String correo;
  final String organizacion;
  final String? token;

  User({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.organizacion,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      correo: json['correo'] as String,
      organizacion: json['organizacion'] as String,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'organizacion': organizacion,
      if (token != null) 'token': token,
    };
  }

  User copyWith({
    int? id,
    String? nombre,
    String? correo,
    String? organizacion,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      organizacion: organizacion ?? this.organizacion,
      token: token ?? this.token,
    );
  }
}
