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
      id: json['id'] as int? ?? 0,
      // Backend uses 'name', frontend uses 'nombre'
      nombre: json['name'] as String? ?? json['nombre'] as String? ?? '',
      // Backend uses 'email', frontend uses 'correo'
      correo: json['email'] as String? ?? json['correo'] as String? ?? '',
      // Backend doesn't return 'organizacion' in User object usually
      organizacion: json['organizacion'] as String? ?? 'Empresa',
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
