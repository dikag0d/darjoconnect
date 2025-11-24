import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:darjoconnect/api_connection/api_connection.dart';// Import file API connection
import 'package:darjoconnect/screens/user/main_screen.dart';
import 'package:darjoconnect/screens/registration_screen.dart';
import 'package:darjoconnect/screens/admin_kebakaran/fire_department_screen.dart';
import 'package:darjoconnect/screens/admin_banjir/flood_department_screen.dart';
import 'package:darjoconnect/screens/admin_listrik/power_department_screen.dart';
import 'package:darjoconnect/screens/admin_medis/health_department_screen.dart';
import 'package:darjoconnect/screens/admin_jalan/road_department_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Fungsi untuk menangani login
  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi input kosong
    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Email dan password harus diisi!');
      return;
    }

    try {
      // Gunakan URL dari API class
      final url = Uri.parse(API.login);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          // Simpan data pengguna ke SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('userName', data['data']['nama']);
          prefs.setString('userEmail', data['data']['email']);
          prefs.setInt('userId', data['data']['id']);
          prefs.setString('role', data['data']['role']);

          // Arahkan pengguna sesuai role
          String role = data['data']['role'].toLowerCase();
          Widget destinationScreen;

          if (role == 'warga') {
            destinationScreen = const MainScreen();
          } else if (role == 'kebakaran') {
            destinationScreen = const FireDepartmentScreen();
          } else if (role == 'banjir') {
            destinationScreen = const FloodDepartmentScreen();
          } else if (role == 'pemadaman listrik') {
            destinationScreen = const PowerDepartmentScreen();
          } else if (role == 'kesehatan') {
            destinationScreen = const HealthDepartmentScreen();
          } else if (role == 'jalan') {
            destinationScreen = const RoadDepartmentScreen();
          } else {
            destinationScreen = const MainScreen();
          }

          // Navigasi ke halaman sesuai role
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => destinationScreen),
          );
        } else {
          // Tampilkan pesan error jika login gagal
          _showErrorDialog(data['message']);
        }
      } else {
        _showErrorDialog('Terjadi kesalahan, coba lagi nanti.');
      }
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan koneksi, coba lagi nanti.');
    }
  }

  // Fungsi untuk menampilkan dialog error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.login, size: 40),
                  const SizedBox(height: 16),
                  const Text(
                    "Log In",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
    'Sign In',
    style: TextStyle(color: Colors.white), ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistrationScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Registrasi",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
