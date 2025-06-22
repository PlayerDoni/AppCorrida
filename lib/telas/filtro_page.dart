import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TelaFiltro extends StatefulWidget {
  const TelaFiltro({super.key});

  @override
  State<TelaFiltro> createState() => _TelaFiltroState();
}

class _TelaFiltroState extends State<TelaFiltro> {
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController distanciaMinController = TextEditingController();
  final TextEditingController distanciaMaxController = TextEditingController();

  String? tipoSelecionado = 'Todos';
  DateTime? dataInicial;
  DateTime? dataFinal;
  double? distanciaMin;
  double? distanciaMax;
  String tipoOrdenacao = 'Data';
  String ordenacao = 'Data (Mais recente)';

  Future<void> _selecionarDataInicial(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dataInicial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != dataInicial) {
      setState(() {
        dataInicial = picked;
      });
    }
  }

  Future<void> _selecionarDataFinal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dataFinal ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != dataFinal) {
      setState(() {
        dataFinal = picked;
      });
    }
  }

  String formatarData(DateTime? data) {
    if (data == null) return 'Selecionar data';
    return DateFormat('dd/MM/yyyy').format(data);
  }

  void _limparFiltros() {
    setState(() {
      descricaoController.clear();
      distanciaMinController.clear();
      distanciaMaxController.clear();
      tipoSelecionado = 'Todos';
      dataInicial = null;
      dataFinal = null;
      distanciaMin = null;
      distanciaMax = null;
      tipoOrdenacao = 'Data';
      ordenacao = 'Data (Mais recente)';
    });
  }

  void _aplicarFiltros() {
    if (dataInicial != null && dataFinal != null && dataInicial!.isAfter(dataFinal!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A data inicial deve ser anterior à data final')),
      );
      return;
    }
    if (distanciaMin != null && distanciaMax != null && distanciaMin! > distanciaMax!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Distância mínima não pode ser maior que máxima')),
      );
      return;
    }

    Navigator.pop(context, {
      'descricao': descricaoController.text.trim(),
      'tipo': tipoSelecionado,
      'dataInicial': dataInicial,
      'dataFinal': dataFinal,
      'distanciaMin': distanciaMin,
      'distanciaMax': distanciaMax,
      'tipoOrdenacao': tipoOrdenacao,
      'ordenacao': ordenacao,
    });
  }

  @override
  void dispose() {
    descricaoController.dispose();
    distanciaMinController.dispose();
    distanciaMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtros'),
        backgroundColor: const Color(0xFF38B6FF),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Descrição:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Filtrar por descrição',
              ),
            ),
            const SizedBox(height: 20),

            const Text('Tipo de Atividade:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: tipoSelecionado,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                DropdownMenuItem(value: 'Corrida', child: Text('Corrida')),
                DropdownMenuItem(value: 'Caminhada', child: Text('Caminhada')),
              ],
              onChanged: (valor) {
                setState(() {
                  tipoSelecionado = valor;
                });
              },
            ),
            const SizedBox(height: 20),

            const Text('Intervalo de Data:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selecionarDataInicial(context),
                    child: Text(formatarData(dataInicial)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selecionarDataFinal(context),
                    child: Text(formatarData(dataFinal)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Distância (metros):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: distanciaMinController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Mínima',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (valor) {
                      setState(() {
                        distanciaMin = double.tryParse(valor);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: distanciaMaxController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Máxima',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (valor) {
                      setState(() {
                        distanciaMax = double.tryParse(valor);
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Ordenar por:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: tipoOrdenacao,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Data', child: Text('Data')),
                DropdownMenuItem(value: 'Distância', child: Text('Distância')),
              ],
              onChanged: (valor) {
                setState(() {
                  tipoOrdenacao = valor ?? 'Data';
                  if (tipoOrdenacao == 'Data') {
                    ordenacao = 'Data (Mais recente)';
                  } else if (tipoOrdenacao == 'Distância') {
                    ordenacao = 'Distância (Maior)';
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: ordenacao,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: tipoOrdenacao == 'Data'
                  ? const [
                DropdownMenuItem(value: 'Data (Mais recente)', child: Text('Data (Mais recente)')),
                DropdownMenuItem(value: 'Data (Mais antiga)', child: Text('Data (Mais antiga)')),
              ]
                  : const [
                DropdownMenuItem(value: 'Distância (Maior)', child: Text('Distância (Maior)')),
                DropdownMenuItem(value: 'Distância (Menor)', child: Text('Distância (Menor)')),
              ],
              onChanged: (valor) {
                setState(() {
                  ordenacao = valor ?? ordenacao;
                });
              },
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  ),
                  onPressed: _limparFiltros,
                  child: const Text('Limpar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38B6FF),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  ),
                  onPressed: _aplicarFiltros,
                  child: const Text('Aplicar'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
