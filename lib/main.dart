import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rutinas Suaves',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const MenuScreen(),
    );
  }
}

// MENU PRINCIPAL
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Rutinas Suaves",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuButton(context, "Nivel 1 - Sedentario", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RutinaDescripcionScreen(
                    titulo: "Rutinas Nivel 1",
                    ejercicios: [
                      {"nombre": "Marcha", "duracion": 2},
                      {"nombre": "Rotación de hombros", "duracion": 3},
                      {"nombre": "Estiramiento lateral", "duracion": 4},
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            _buildMenuButton(context, "Nivel 2 - Principalmente activo", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RutinaDescripcionScreen(
                    titulo: "Rutinas Nivel 2",
                    ejercicios: [
                      {"nombre": "Caminata ligera", "duracion": 5},
                      {"nombre": "Rotación de brazos", "duracion": 3},
                      {"nombre": "Estiramiento de piernas", "duracion": 4},
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            _buildMenuButton(context, "Nivel 3 - Adaptación intermedia", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RutinaDescripcionScreen(
                    titulo: "Rutinas Nivel 3",
                    ejercicios: [
                      {"nombre": "Marcha rápida", "duracion": 5},
                      {"nombre": "Elevación de brazos", "duracion": 4},
                      {"nombre": "Estiramiento lateral + torso", "duracion": 5},
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

//  PANTALLA DE DESCRIPCIÓN PREVIA
class RutinaDescripcionScreen extends StatelessWidget {
  final String titulo;
  final List<Map<String, dynamic>> ejercicios;

  const RutinaDescripcionScreen({
    super.key,
    required this.titulo,
    required this.ejercicios,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Ejercicios de la rutina:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: ejercicios.length,
                itemBuilder: (context, index) {
                  final ejercicio = ejercicios[index];
                  return ListTile(
                    leading: const Icon(Icons.fitness_center),
                    title: Text(ejercicio["nombre"]),
                    trailing: Text("${ejercicio["duracion"]} min"),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RutinaScreen(titulo: titulo, ejercicios: ejercicios),
                    ),
                  );
                },
                child: const Text("Iniciar", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  PANTALLA DE CRONÓMETRO
class RutinaScreen extends StatefulWidget {
  final String titulo;
  final List<Map<String, dynamic>> ejercicios;

  const RutinaScreen({
    super.key,
    required this.titulo,
    required this.ejercicios,
  });

  @override
  State<RutinaScreen> createState() => _RutinaScreenState();
}

class _RutinaScreenState extends State<RutinaScreen> {
  int indexActual = 0;
  late int segundosRestantes;
  Timer? timer;
  bool pausado = false;

  @override
  void initState() {
    super.initState();
    segundosRestantes = widget.ejercicios[indexActual]["duracion"] * 60;
    _iniciarTimer();
  }

  void _iniciarTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!pausado) {
        setState(() {
          if (segundosRestantes > 0) {
            segundosRestantes--;
          } else {
            _siguienteEjercicio();
          }
        });
      }
    });
  }

  void _pausarReanudar() {
    setState(() {
      pausado = !pausado;
    });
  }

  void _siguienteEjercicio() {
    if (indexActual < widget.ejercicios.length - 1) {
      setState(() {
        indexActual++;
        segundosRestantes = widget.ejercicios[indexActual]["duracion"] * 60;
      });
    } else {
      _finalizarRutina();
    }
  }

  void _finalizarRutina() {
    timer?.cancel();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rutina finalizada"),
        content: const Text("¡Felicidades! Completaste la rutina."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  String _formatearTiempo(int segundos) {
    final m = (segundos ~/ 60).toString().padLeft(2, '0');
    final s = (segundos % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ejercicio = widget.ejercicios[indexActual];
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.titulo} (${ejercicio['nombre']})"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ejercicio["nombre"],
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              _formatearTiempo(segundosRestantes),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _pausarReanudar,
                  child: Text(pausado ? "Reanudar" : "Pausa"),
                ),
                ElevatedButton(
                  onPressed: _siguienteEjercicio,
                  child: const Text("Siguiente"),
                ),
                ElevatedButton(
                  onPressed: _finalizarRutina,
                  child: const Text("Finalizar"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
