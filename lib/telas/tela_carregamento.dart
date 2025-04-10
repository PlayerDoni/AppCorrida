import 'package:flutter/material.dart';
import 'dart:async';
import 'tela_inicial.dart';

class TelaCarregamento extends StatefulWidget {
  const TelaCarregamento({super.key});

  @override
  State<TelaCarregamento> createState() => _TelaCarregamentoState();
}

class _TelaCarregamentoState extends State<TelaCarregamento> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TelaInicial()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF38B6FF),
      body: Center(
        child: SizedBox(
          width: 400,
          height: 400,
          child: Image(
            image: AssetImage('assets/LogoGeoSprint.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
