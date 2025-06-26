import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geosprint/telas/nova_corrida.dart';
import 'package:geosprint/telas/filtro_page.dart';
import 'package:geosprint/models/corrida.dart';
import 'package:geosprint/dados/dados_corridas.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  List<Corrida> listaFiltradaCorridas = List.from(listaCorridas);
  double? temperatura;
  String? descricaoClima;
  String? cidade;

  @override
  void initState() {
    super.initState();
    _carregarCorridas();
    _buscarClimaPelaLocalizacao();
  }

  Future<void> _buscarClimaPelaLocalizacao() async {
    try {
      bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicoHabilitado) return;

      LocationPermission permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
        if (permissao == LocationPermission.denied) return;
      }

      if (permissao == LocationPermission.deniedForever) return;

      Position posicao = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      WeatherFactory wf = WeatherFactory("58b702a16e0bacb5f09377f82b9b71ae", language: Language.PORTUGUESE);
      Weather clima = await wf.currentWeatherByLocation(
        posicao.latitude,
        posicao.longitude,
      );

      setState(() {
        cidade = "Local Atual";
        temperatura = clima.temperature?.celsius;
        descricaoClima = clima.weatherDescription;
      });
    } catch (e) {
      print("Erro ao buscar clima/localização: $e");
    }
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

          return _correspondeTipo(corrida, tipoSelecionado) &&
              _correspondeData(corrida, dataInicial, dataFinal) &&
              _correspondeDistancia(corrida, distanciaMin, distanciaMax) &&
              _correspondeDescricao(corrida, descricaoFiltro);
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

  bool _correspondeTipo(Corrida corrida, String? tipoSelecionado) {
    return tipoSelecionado == null ||
        tipoSelecionado == 'Todos' ||
        corrida.tipo == tipoSelecionado;
  }

  bool _correspondeData(Corrida corrida, DateTime? dataInicial, DateTime? dataFinal) {
    if (dataInicial == null || dataFinal == null) return true;
    return corrida.data.isAfter(dataInicial.subtract(const Duration(days: 1))) &&
        corrida.data.isBefore(dataFinal.add(const Duration(days: 1)));
  }

  bool _correspondeDistancia(Corrida corrida, double? min, double? max) {
    if (min == null || max == null) return true;
    return corrida.distancia >= min && corrida.distancia <= max;
  }

  bool _correspondeDescricao(Corrida corrida, String descricaoFiltro) {
    return descricaoFiltro.isEmpty ||
        corrida.descricao.toLowerCase().contains(descricaoFiltro);
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
    bool textoAlterado = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
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
                    onChanged: (valor) {
                      setStateDialog(() {
                        textoAlterado = valor.trim().isNotEmpty && valor != corrida.descricao;
                      });
                    },
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
                  onPressed: textoAlterado
                      ? () {
                    setState(() {
                      corrida.descricao = controller.text;
                    });
                    _salvarCorridas();
                    Navigator.pop(context);
                  }
                      : null,
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: const Color(0xFF38B6FF),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud, color: Colors.white, size: 30),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        cidade == null || temperatura == null
                            ? 'Buscando clima atual...'
                            : '$cidade: ${temperatura!.toStringAsFixed(1)}°C • $descricaoClima',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: listaFiltradaCorridas.isEmpty
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
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        'Distância: ${corrida.distancia.toStringAsFixed(0)} m',
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
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Editar Descrição',
                        onPressed: () => _editarDescricao(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Excluir Atividade',
                        onPressed: () => _excluirCorrida(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF38B6FF),
        onPressed: _abrirNovaCorrida,
        tooltip: 'Nova Corrida',
        child: const Icon(Icons.add),
      ),
    );
  }
}
