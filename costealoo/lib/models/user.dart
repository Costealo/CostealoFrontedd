class User {
  final int id;
  final String nombre;
  final String correo;
  final String organizacion;
  final String? token;
  final String? tipoSuscripcion;
  final String? tarjetaUltimos4Digitos;
  final String? tarjetaCodigoSeguridad;
  final String? tarjetaFechaVencimiento;

  User({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.organizacion,
    this.token,
    this.tipoSuscripcion,
    this.tarjetaUltimos4Digitos,
    this.tarjetaCodigoSeguridad,
    this.tarjetaFechaVencimiento,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      nombre: json['nombre'] as String? ?? '',
      correo: json['email'] as String? ?? json['correo'] as String? ?? '',
      organizacion: json['organizacion'] as String? ?? 'Empresa',
      token: json['token'] as String?,
      tipoSuscripcion: json['tipoSuscripcion'] as String?,
      tarjetaUltimos4Digitos: json['tarjetaUltimos4Digitos'] as String?,
      tarjetaCodigoSeguridad: json['tarjetaCodigoSeguridad'] as String?,
      tarjetaFechaVencimiento: json['tarjetaFechaVencimiento'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': correo,
      'organizacion': organizacion,
      if (token != null) 'token': token,
      if (tipoSuscripcion != null) 'tipoSuscripcion': tipoSuscripcion,
      if (tarjetaUltimos4Digitos != null)
        'tarjetaUltimos4Digitos': tarjetaUltimos4Digitos,
      if (tarjetaCodigoSeguridad != null)
        'tarjetaCodigoSeguridad': tarjetaCodigoSeguridad,
      if (tarjetaFechaVencimiento != null)
        'tarjetaFechaVencimiento': tarjetaFechaVencimiento,
    };
  }

  User copyWith({
    int? id,
    String? nombre,
    String? correo,
    String? organizacion,
    String? token,
    String? tipoSuscripcion,
    String? tarjetaUltimos4Digitos,
    String? tarjetaCodigoSeguridad,
    String? tarjetaFechaVencimiento,
  }) {
    return User(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      organizacion: organizacion ?? this.organizacion,
      token: token ?? this.token,
      tipoSuscripcion: tipoSuscripcion ?? this.tipoSuscripcion,
      tarjetaUltimos4Digitos:
          tarjetaUltimos4Digitos ?? this.tarjetaUltimos4Digitos,
      tarjetaCodigoSeguridad:
          tarjetaCodigoSeguridad ?? this.tarjetaCodigoSeguridad,
      tarjetaFechaVencimiento:
          tarjetaFechaVencimiento ?? this.tarjetaFechaVencimiento,
    );
  }
}
