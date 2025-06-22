import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'registro_corrida.dart';

class NovaCorrida extends StatefulWidget {
  const NovaCorrida({super.key});

  @override
  State<NovaCorrida> createState() => _NovaCorridaState();
}

class _NovaCorridaState extends State<NovaCorrida> with TickerProviderStateMixin {
  bool emAndamento = false;
  double distancia = 0.0; // distância em metros
  Duration tempo = Duration.zero;
  late Stopwatch cronometro;
  late final Ticker _ticker;

  // === Variáveis do GPS ===
  StreamSubscription<Position>? _subscription;
  Position? _ultimaLocalizacaoConhecida;
  double _calculoDistancia = 0;
  bool _monitorandoLocalizacao = false;

  @override
  void initState() {
    super.initState();
    cronometro = Stopwatch();
    _ticker = createTicker(_onTick);
  }

  void _onTick(Duration elapsed) {
    setState(() {
      tempo = cronometro.elapsed;
    });
  }

  // === Métodos do GPS ===
  Future<void> _iniciarMonitoramento() async {
    bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de localização negada!')),
        );
        return;
      }
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
    );

    _subscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      if (position.accuracy > 30) {
        return;
      }

      if (_ultimaLocalizacaoConhecida != null) {
        final distanciaIncremento = Geolocator.distanceBetween(
          _ultimaLocalizacaoConhecida!.latitude,
          _ultimaLocalizacaoConhecida!.longitude,
          position.latitude,
          position.longitude,
        );

        _ultimaLocalizacaoConhecida = position;

        if (distanciaIncremento >= 0.5 && distanciaIncremento < 20) {
          _calculoDistancia += distanciaIncremento;
          setState(() {
            distancia = _calculoDistancia;
          });
        }
      } else {
        _ultimaLocalizacaoConhecida = position;
      }
    });

    setState(() {
      _monitorandoLocalizacao = true;
      _calculoDistancia = 0;
      _ultimaLocalizacaoConhecida = null;
      distancia = 0.0;
    });
  }

  void _pararMonitoramento() {
    _subscription?.cancel();
    _subscription = null;
    setState(() {
      _monitorandoLocalizacao = false;
    });
  }

  void _cancelarMonitoramento() {
    _subscription?.cancel();
    _subscription = null;
    setState(() {
      _monitorandoLocalizacao = false;
      _calculoDistancia = 0;
      _ultimaLocalizacaoConhecida = null;
      distancia = 0.0;
    });
  }

  // === Controle da corrida ===

  void iniciarCorrida() {
    setState(() {
      emAndamento = true;
      cronometro.start();
      _ticker.start();
    });
    _iniciarMonitoramento();
  }

  void pausarCorrida() {
    setState(() {
      cronometro.stop();
      _ticker.stop();
    });
  }

  void retomarCorrida() {
    setState(() {
      cronometro.start();
      _ticker.start();
    });
  }

  void encerrarCorrida() async {
    setState(() {
      cronometro.stop();
      _ticker.stop();
      emAndamento = false;
    });
    _pararMonitoramento();

    final corridaRegistrada = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroCorrida(
          tempo: tempo,
          distancia: distancia, // passa em metros diretamente
        ),
      ),
    );

    if (corridaRegistrada == true) {
      // Retorna true para a tela anterior indicar que salvou com sucesso
      Navigator.pop(context, true);
    }
  }

  void cancelarCorrida() {
    setState(() {
      cronometro.stop();
      _ticker.stop();
      cronometro.reset();
      tempo = Duration.zero;
      distancia = 0.0;
      emAndamento = false;
    });
    _cancelarMonitoramento();

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  // === Função de formatação da distância ===
  String formatarDistancia(double distanciaEmMetros) {
    return '${distanciaEmMetros.toStringAsFixed(0)} m';
  }

  @override
  Widget build(BuildContext context) {
    String tempoFormatado =
        "${tempo.inMinutes.toString().padLeft(2, '0')}:${(tempo.inSeconds % 60).toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF38B6FF),
        centerTitle: true,
        title: const Text(
          'Nova Corrida',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Tempo: $tempoFormatado',
              style: const TextStyle(fontSize: 28),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Distância: ${formatarDistancia(distancia)}',
              style: const TextStyle(fontSize: 28),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (!emAndamento)
              ElevatedButton(
                onPressed: iniciarCorrida,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[300],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Iniciar', style: TextStyle(fontSize: 16)),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: cronometro.isRunning ? pausarCorrida : retomarCorrida,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[300],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      cronometro.isRunning ? 'Pausar' : 'Retomar',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: encerrarCorrida,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Encerrar', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: cancelarCorrida,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
