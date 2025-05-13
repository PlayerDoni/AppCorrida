import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geosprint/telas/nova_corrida.dart';
import 'package:geosprint/telas/filtro_page.dart';
import 'package:geosprint/models/corrida.dart';
import 'package:geosprint/dados/dados_corridas.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  List<Corrida> listaFiltradaCorridas = List.from(listaCorridas);

  @override
  void initState() {
    super.initState();
    _carregarCorridas();
  }

  void _abrirNovaCorrida() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NovaCorrida(),
      ),
    );

    if (resultado == true) {
      setState(() {
        listaFiltradaCorridas = List.from(listaCorridas);
      });
      _salvarCorridas();
    }
  }

  void _abrirTelaFiltro() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaFiltro()),
    );

    if (resultado != null && resultado is Map<String, dynamic>) {
      setState(() {
        listaFiltradaCorridas = listaCorridas.where((corrida) {
          final tipoSelecionado = resultado['tipo'];
          final dataInicial = resultado['dataInicial'];
          final dataFinal = resultado['dataFinal'];
          final distanciaMin = resultado['distanciaMin'];
          final distanciaMax = resultado['distanciaMax'];
          final descricaoFiltro = (resultado['descricao'] ?? '').toLowerCase();

          bool correspondeTipo = tipoSelecionado == null ||
              tipoSelecionado == 'Todos' ||
              corrida.tipo == tipoSelecionado;

          bool correspondeData = true;
          if (dataInicial != null && dataFinal != null) {
            correspondeData = corrida.data.isAfter(dataInicial.subtract(const Duration(days: 1))) &&
                corrida.data.isBefore(dataFinal.add(const Duration(days: 1)));
          }

          bool correspondeDistancia = true;
          if (distanciaMin != null && distanciaMax != null) {
            correspondeDistancia = corrida.distancia >= distanciaMin && corrida.distancia <= distanciaMax;
          }

          bool correspondeDescricao = descricaoFiltro.isEmpty ||
              corrida.descricao.toLowerCase().contains(descricaoFiltro);

          return correspondeTipo && correspondeData && correspondeDistancia && correspondeDescricao;
        }).toList();

        final tipoOrdenacao = resultado['tipoOrdenacao'];
        final ordenacao = resultado['ordenacao'];

        if (tipoOrdenacao == 'Data') {
          listaFiltradaCorridas.sort((a, b) =>
          ordenacao == 'Data (Mais recente)'
              ? b.data.compareTo(a.data)
              : a.data.compareTo(b.data));
        } else if (tipoOrdenacao == 'Distância') {
          listaFiltradaCorridas.sort((a, b) =>
          ordenacao == 'Distância (Maior)'
              ? b.distancia.compareTo(a.distancia)
              : a.distancia.compareTo(b.distancia));
        }
      });
    }
  }

  void _excluirCorrida(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Atividade'),
        content: const Text('Tem certeza que deseja excluir esta atividade?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final corrida = listaFiltradaCorridas[index];
              setState(() {
                listaCorridas.remove(corrida);
                listaFiltradaCorridas.removeAt(index);
              });
              _salvarCorridas();
              Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editarDescricao(int index) {
    final corrida = listaFiltradaCorridas[index];
    final TextEditingController controller = TextEditingController(text: corrida.descricao);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Descrição'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Digite a nova descrição',
                hintStyle: TextStyle(fontSize: 16),
                contentPadding: EdgeInsets.only(bottom: 6),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(thickness: 1),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                corrida.descricao = controller.text;
              });
              _salvarCorridas();
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  String formatarDataHora(DateTime data) {
    return DateFormat('dd/MM/yyyy • HH:mm').format(data);
  }

  Future<void> _salvarCorridas() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> corridasJson = listaCorridas.map((corrida) {
      final json = corrida.toJson();
      return jsonEncode(json);
    }).toList();
    await prefs.setStringList('corridas', corridasJson);
  }

  Future<void> _carregarCorridas() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? corridasJson = prefs.getStringList('corridas');
    if (corridasJson != null) {
      setState(() {
        listaCorridas = corridasJson.map((json) {
          final Map<String, dynamic> corridaMap = jsonDecode(json);
          return Corrida.fromJson(corridaMap);
        }).toList();
        listaFiltradaCorridas = List.from(listaCorridas);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF38B6FF),
        centerTitle: true,
        title: const Text(
          'Vamos Correr 🏃‍♂️',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: _abrirTelaFiltro,
          ),
        ],
      ),
      body: listaFiltradaCorridas.isEmpty
          ? const Center(
        child: Text(
          'Nenhuma corrida registrada ainda',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.separated(
        itemCount: listaFiltradaCorridas.length,
        separatorBuilder: (context, index) => const Divider(
          thickness: 1,
          color: Colors.grey,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final corrida = listaFiltradaCorridas[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              'Atividade ${index + 1} - ${corrida.tipo}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Data: ${formatarDataHora(corrida.data)}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Distância: ${corrida.distancia.toStringAsFixed(2)} km',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Descrição: ${corrida.descricao}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF00FF00)),
                  onPressed: () => _editarDescricao(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _excluirCorrida(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF38B6FF),
        onPressed: _abrirNovaCorrida,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
