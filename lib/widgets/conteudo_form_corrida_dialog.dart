import 'package:flutter/material.dart';
import 'package:geosprint/models/corrida.dart';
import 'package:intl/intl.dart';

class ConteudoFormCorridaDialog extends StatefulWidget {
  final Corrida? corridaAtual;

  const ConteudoFormCorridaDialog({Key? key, this.corridaAtual}) : super(key: key);

  @override
  State<ConteudoFormCorridaDialog> createState() => _ConteudoFormCorridaDialogState();
}

class _ConteudoFormCorridaDialogState extends State<ConteudoFormCorridaDialog> {
  final formKey = GlobalKey<FormState>();
  final descricaoController = TextEditingController();
  final dataController = TextEditingController();
  final horaController = TextEditingController();
  final tempoController = TextEditingController();
  final distanciaController = TextEditingController();
  String tipoSelecionado = 'corrida';

  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _timeFormat = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    if (widget.corridaAtual != null) {
      descricaoController.text = widget.corridaAtual!.descricao;
      dataController.text = _dateFormat.format(widget.corridaAtual!.data);
      horaController.text = TimeOfDay.fromDateTime(widget.corridaAtual!.hora).format(context);
      tempoController.text = widget.corridaAtual!.tempo.inMinutes.toString();
      distanciaController.text = widget.corridaAtual!.distancia.toString();
      tipoSelecionado = widget.corridaAtual!.tipo;
    }
  }

  @override
  void dispose() {
    descricaoController.dispose();
    dataController.dispose();
    horaController.dispose();
    tempoController.dispose();
    distanciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: tipoSelecionado,
              items: ['corrida', 'caminhada']
                  .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                  .toList(),
              onChanged: (valor) => setState(() => tipoSelecionado = valor!),
              decoration: InputDecoration(labelText: 'Tipo'),
            ),
            TextFormField(
              controller: descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
              validator: (valor) =>
              valor == null || valor.isEmpty ? 'O campo descrição é obrigatório' : null,
            ),
            TextFormField(
              controller: dataController,
              decoration: InputDecoration(
                labelText: 'Data',
                prefixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: _mostrarCalendario,
                ),
              ),
              readOnly: true,
              validator: (valor) => valor == null || valor.isEmpty ? 'Selecione uma data' : null,
            ),
            TextFormField(
              controller: horaController,
              decoration: InputDecoration(
                labelText: 'Hora',
                prefixIcon: IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: _mostrarRelogio,
                ),
              ),
              readOnly: true,
              validator: (valor) => valor == null || valor.isEmpty ? 'Selecione uma hora' : null,
            ),
            TextFormField(
              controller: tempoController,
              decoration: InputDecoration(labelText: 'Tempo (minutos)'),
              keyboardType: TextInputType.number,
              validator: (valor) {
                if (valor == null || valor.isEmpty) return 'Informe o tempo em minutos';
                final numero = int.tryParse(valor);
                if (numero == null || numero <= 0) return 'Tempo inválido';
                return null;
              },
            ),
            TextFormField(
              controller: distanciaController,
              decoration: InputDecoration(labelText: 'Distância (km)'),
              keyboardType: TextInputType.number,
              validator: (valor) {
                if (valor == null || valor.isEmpty) return 'Informe a distância';
                final numero = double.tryParse(valor);
                if (numero == null || numero <= 0) return 'Distância inválida';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarCalendario() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 5 * 365)),
      lastDate: DateTime.now().add(Duration(days: 5 * 365)),
    ).then((dataSelecionada) {
      if (dataSelecionada != null) {
        setState(() {
          dataController.text = _dateFormat.format(dataSelecionada);
        });
      }
    });
  }

  void _mostrarRelogio() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((horaSelecionada) {
      if (horaSelecionada != null) {
        setState(() {
          horaController.text = horaSelecionada.format(context);
        });
      }
    });
  }

  bool dadosValidados() => formKey.currentState?.validate() == true;

  Corrida get novaCorrida => Corrida(
    id: widget.corridaAtual?.id,
    tipo: tipoSelecionado,
    descricao: descricaoController.text,
    data: _dateFormat.parse(dataController.text),
    hora: _horaToDateTime(horaController.text),
    tempo: Duration(minutes: int.parse(tempoController.text)),
    distancia: double.parse(distanciaController.text),
  );

  DateTime _horaToDateTime(String horaFormatada) {
    final partes = horaFormatada.split(':');
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month, agora.day, int.parse(partes[0]), int.parse(partes[1]));
  }
}
