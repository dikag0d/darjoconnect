import 'package:flutter/material.dart';


class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Warna latar belakang
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/app.png', width: 100, height: 100),
            const SizedBox(height: 20),
            const CircularProgressIndicator(), // Indikator loading
            const SizedBox(height: 10),
            const Text(
              "Memuat...",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
