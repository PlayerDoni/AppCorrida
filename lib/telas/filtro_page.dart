import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TelaFiltro extends StatefulWidget {
  const TelaFiltro({super.key});

  @override
  State<TelaFiltro> createState() => _TelaFiltroState();
}

class _TelaFiltroState extends State<TelaFiltro> {
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _distanciaMinController = TextEditingController();
  final TextEditingController _distanciaMaxController = TextEditingController();

  DateTime? _dataInicial;
  DateTime? _dataFinal;
  String _tipoSelecionado = 'Todos';
  String _ordenacaoSelecionada = 'Data (Mais recente)';

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'pt_BR';
  }

  Future<void> _selecionarData(BuildContext context, bool isInicial) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );

    if (dataSelecionada != null) {
      setState(() {
        if (isInicial) {
          _dataInicial = dataSelecionada;
        } else {
          _dataFinal = dataSelecionada;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final estiloFonte = const TextStyle(fontSize: 16, color: Colors.black);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtrar atividades'),
        backgroundColor: const Color(0xFF38B6FF),
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            TextField(
              controller: _descricaoController,
              style: estiloFonte,
              decoration: const InputDecoration(
                labelText: 'Buscar por descrição',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),


            DropdownButtonFormField<String>(
              value: _tipoSelecionado,
              style: estiloFonte,
              dropdownColor: Colors.white,
              items: ['Todos', 'Corrida', 'Caminhada']
                  .map((tipo) => DropdownMenuItem(
                value: tipo,
                child: Text(tipo, style: estiloFonte),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _tipoSelecionado = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Tipo de atividade',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _selecionarData(context, true),
                  icon: const Icon(Icons.calendar_today, size: 18, color: Colors.black),
                  label: Text(
                    _dataInicial == null
                        ? 'Data inicial'
                        : DateFormat('dd/MM/yyyy').format(_dataInicial!),
                    style: estiloFonte,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _selecionarData(context, false),
                  icon: const Icon(Icons.calendar_today, size: 18, color: Colors.black),
                  label: Text(
                    _dataFinal == null
                        ? 'Data final'
                        : DateFormat('dd/MM/yyyy').format(_dataFinal!),
                    style: estiloFonte,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),


            TextField(
              controller: _distanciaMinController,
              style: estiloFonte,
              decoration: const InputDecoration(
                labelText: 'Distância mínima (km)',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),


            TextField(
              controller: _distanciaMaxController,
              style: estiloFonte,
              decoration: const InputDecoration(
                labelText: 'Distância máxima (km)',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),


            DropdownButtonFormField<String>(
              value: _ordenacaoSelecionada,
              style: estiloFonte,
              dropdownColor: Colors.white,
              items: [
                'Data (Mais recente)',
                'Data (Mais antiga)',
                'Distância (Maior)',
                'Distância (Menor)',
              ].map((ordem) => DropdownMenuItem(
                value: ordem,
                child: Text(ordem, style: estiloFonte),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _ordenacaoSelecionada = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Ordenar por',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    String tipoOrdenacao = _ordenacaoSelecionada.contains('Data')
                        ? 'Data'
                        : 'Distância';

                    Navigator.pop(context, {
                      'descricao': _descricaoController.text,
                      'tipo': _tipoSelecionado,
                      'dataInicial': _dataInicial,
                      'dataFinal': _dataFinal,
                      'distanciaMin': _distanciaMinController.text,
                      'distanciaMax': _distanciaMaxController.text,
                      'ordenacao': _ordenacaoSelecionada,
                      'tipoOrdenacao': tipoOrdenacao,
                    });
                  },
                  icon: const Icon(Icons.check, size: 18, color: Colors.black),
                  label: const Text(
                    'Aplicar Filtros',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38B6FF),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _descricaoController.clear();
                      _distanciaMinController.clear();
                      _distanciaMaxController.clear();
                      _tipoSelecionado = 'Todos';
                      _dataInicial = null;
                      _dataFinal = null;
                      _ordenacaoSelecionada = 'Data (Mais recente)';
                    });
                  },
                  icon: const Icon(Icons.clear, size: 18, color: Colors.black),
                  label: const Text(
                    'Limpar Filtros',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
