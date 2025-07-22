import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String backendUrl = 'http://10.0.2.2:3000'; // Cambia si usas otro entorno

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Authentication',
      home: const AuthExample(),
    );
  }
}

class AuthExample extends StatefulWidget {
  const AuthExample({super.key});

  @override
  AuthExampleState createState() => AuthExampleState();
}

class AuthExampleState extends State<AuthExample> {
  String status = "Verificando autenticación...";
  String greeting = "";

  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  void checkAuthStatus() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      if (user != null) {
        status = user.isAnonymous
            ? "El usuario está autenticado anónimamente"
            : "El usuario está autenticado";
      } else {
        status = "El usuario no está autenticado";
      }
    });
  }

  void signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      setState(() {
        status = "El usuario está autenticado anónimamente";
        greeting = "";
      });
    } catch (e) {
      setState(() {
        status = "Error: $e";
      });
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      status = "El usuario no está autenticado";
      greeting = "";
    });
  }

  void getGreeting() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showAlert("No autenticado", "Debes iniciar sesión para ver el saludo.");
      return;
    }

    try {
      final response = await http.get(Uri.parse('$backendUrl/saludo'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        showAlert("Saludo del backend", data['mensaje']);
      } else {
        showAlert("Error", "Código de estado: ${response.statusCode}");
      }
    } catch (e) {
      showAlert("Error de red", e.toString());
    }
  }

  void showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Autenticación con Firebase")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              status,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: getGreeting,
              child: const Text("Obtener saludo del backend"),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: signInAnonymously,
                  child: const Text("Login anónimo"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: signOut,
                  child: const Text("Cerrar sesión"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
