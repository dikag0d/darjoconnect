import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import class API
import 'package:darjoconnect/api_connection/api_connection.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Controllers untuk menangkap input dari TextField
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Fungsi untuk mengirimkan data registrasi ke server
  Future<void> _registerUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final nik = _nikController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi input di sisi Flutter
    if (name.isEmpty || email.isEmpty || nik.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua bidang harus diisi!')),
      );
      return;
    }

    try {
      // Kirim permintaan POST dengan JSON body
      final response = await http.post(
        Uri.parse(API.registration), // Gunakan API.registration dari api_connection.dart
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nama': name,
          'email': email,
          'nik': nik,
          'password': password,
        }),
      );

      // Decode respon JSON
      final responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );

        // Reset form dan navigasi ke layar berikutnya
        _nameController.clear();
        _emailController.clear();
        _nikController.clear();
        _passwordController.clear();

        // Lakukan navigasi jika berhasil
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Registrasi gagal, coba lagi.')),
        );
      }
    } catch (e) {
      // Tangani error jaringan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat terhubung ke server.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nikController,
                decoration: const InputDecoration(
                  labelText: 'NIK',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _registerUser,
                child: const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
