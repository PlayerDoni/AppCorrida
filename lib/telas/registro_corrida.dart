import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/corrida.dart';
import '../dados/dados_corridas.dart';

class RegistroCorrida extends StatefulWidget {
  final Duration tempo;
  final double distancia;

  const RegistroCorrida({
    Key? key,
    required this.tempo,
    required this.distancia,
  }) : super(key: key);

  @override
  State<RegistroCorrida> createState() => _RegistroCorridaState();
}

class _RegistroCorridaState extends State<RegistroCorrida> {
  final TextEditingController descricaoController = TextEditingController();
  DateTime dataHora = DateTime.now();
  String tipoSelecionado = 'Corrida';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
  }

  void salvarRegistro() {
    String descricao = descricaoController.text.trim();

    if (descricao.isEmpty) {
      descricao = 'Atividade ${listaCorridas.length + 1}';
    }

    final corrida = Corrida(
      tipo: tipoSelecionado,
      descricao: descricao,
      data: dataHora,
      hora: dataHora,
      tempo: widget.tempo,
      distancia: widget.distancia.round().toDouble(), // salva arredondado como double inteiro (ex: 120.0)
    );

    listaCorridas.add(corrida);

    print('Corrida salva!');
    print('Tipo: ${corrida.tipo}');
    print('Descrição: ${corrida.descricao}');
    print('Data: ${DateFormat('dd/MM/yyyy', 'pt_BR').format(corrida.data)}');
    print('Hora: ${DateFormat('HH:mm:ss').format(corrida.hora)}');
    print('Tempo: ${corrida.tempo}');
    print('Distância: ${corrida.distancia} m');
    print('Corridas atuais: $listaCorridas');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro salvo com sucesso!')),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    const estiloTexto = TextStyle(fontSize: 20, color: Colors.black);

    String tempoFormatado =
        "${widget.tempo.inMinutes.toString().padLeft(2, '0')}:${(widget.tempo.inSeconds % 60).toString().padLeft(2, '0')}";

    String distanciaFormatada = widget.distancia.round().toString();

    String dataFormatada = DateFormat('dd/MM/yyyy', 'pt_BR').format(dataHora);
    String horaFormatada = DateFormat('HH:mm:ss').format(dataHora);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Corrida', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFF38B6FF),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Data: $dataFormatada', style: estiloTexto),
                Text('Hora: $horaFormatada', style: estiloTexto),
              ],
            ),
            const SizedBox(height: 24),
            Text('Tempo: $tempoFormatado', style: estiloTexto),
            Text('Distância: $distanciaFormatada m', style: estiloTexto),
            const SizedBox(height: 24),
            TextField(
              controller: descricaoController,
              style: estiloTexto,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                labelStyle: estiloTexto,
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text('Tipo de Atividade:', style: estiloTexto),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          tipoSelecionado = 'Corrida';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tipoSelecionado == 'Corrida'
                            ? const Color(0xFF00FF00)
                            : Colors.grey[300],
                        foregroundColor: Colors.black,
                        textStyle: estiloTexto.copyWith(fontSize: 18),
                        elevation: 0,
                      ),
                      child: const Text('Corrida'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          tipoSelecionado = 'Caminhada';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tipoSelecionado == 'Caminhada'
                            ? const Color(0xFF00FF00)
                            : Colors.grey[300],
                        foregroundColor: Colors.black,
                        textStyle: estiloTexto.copyWith(fontSize: 18),
                        elevation: 0,
                      ),
                      child: const Text('Caminhada'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: salvarRegistro,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: estiloTexto,
                  ),
                  child: const Text('Salvar Atividade'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
