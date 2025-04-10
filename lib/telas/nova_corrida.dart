import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'registro_corrida.dart';

class NovaCorrida extends StatefulWidget {
  const NovaCorrida({super.key});

  @override
  State<NovaCorrida> createState() => _NovaCorridaState();
}

class _NovaCorridaState extends State<NovaCorrida> with TickerProviderStateMixin {
  bool emAndamento = false;
  double distancia = 0.0;
  Duration tempo = Duration.zero;
  late Stopwatch cronometro;
  late final Ticker _ticker;

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

  void iniciarCorrida() {
    setState(() {
      emAndamento = true;
      cronometro.start();
      _ticker.start();
    });
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

    final corridaRegistrada = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroCorrida(
          tempo: tempo,
          distancia: distancia,
        ),
      ),
    );

    if (corridaRegistrada == true) {
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

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
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
              'Distância: ${distancia.toStringAsFixed(2)} km',
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
