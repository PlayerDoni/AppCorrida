class Corrida {
  final String tipo;
  final DateTime data;
  final double distancia;
  final Duration tempo;
  final DateTime hora;
  String descricao;
  int? id;

  static const nomeTabela = 'corridas';
  static const CAMPO_ID = 'id';


  Corrida({
    this.id,
    required this.tipo,
    required this.data,
    required this.distancia,
    required this.descricao,
    required this.tempo,
    required this.hora,
  });

  // Método para converter Corrida em Map (para banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'data': data.toIso8601String(),
      'distancia': distancia,
      'descricao': descricao,
      'tempo': tempo.inMinutes,
      'hora': hora.toIso8601String(),
    };
  }

  // Método para criar uma Corrida a partir de um Map (para banco de dados)
  static Corrida fromMap(Map<String, dynamic> map) {
    return Corrida(
      id: map[CAMPO_ID],
      tipo: map['tipo'],
      data: DateTime.parse(map['data']),
      distancia: map['distancia'],
      descricao: map['descricao'],
      tempo: Duration(minutes: map['tempo']),
      hora: DateTime.parse(map['hora']),
    );
  }

  // Método de serialização para JSON
  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'data': data.toIso8601String(),
      'distancia': distancia,
      'descricao': descricao,
      'tempo': tempo.inMinutes,
      'hora': hora.toIso8601String(),
    };
  }

  // Método de desserialização de JSON
  static Corrida fromJson(Map<String, dynamic> json) {
    return Corrida(
      tipo: json['tipo'],
      data: DateTime.parse(json['data']),
      distancia: json['distancia'],
      descricao: json['descricao'],
      tempo: Duration(minutes: json['tempo']),
      hora: DateTime.parse(json['hora']),
    );
  }
}
