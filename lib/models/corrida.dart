import 'package:flutter/material.dart';

class Corrida {
  final String tipo;
  String descricao;
  final DateTime data;
  final DateTime hora;
  final Duration tempo;
  final double distancia;

  Corrida({
    required this.tipo,
    required this.descricao,
    required this.data,
    required this.hora,
    required this.tempo,
    required this.distancia,
  });

  @override
  String toString() {
    final dataFormatada = "${data.day.toString().padLeft(2, '0')}/"
        "${data.month.toString().padLeft(2, '0')}/"
        "${data.year}";
    final horaFormatada = "${hora.hour.toString().padLeft(2, '0')}:"
        "${hora.minute.toString().padLeft(2, '0')}";
    return 'Corrida(tipo: $tipo, descricao: $descricao, data: $dataFormatada, hora: $horaFormatada, tempo: $tempo, distancia: $distancia km)';
  }
}
