import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:darjoconnect/screens/login_screen.dart';
import 'package:darjoconnect/screens/admin_medis/report_health_detail_screen.dart';
import 'package:darjoconnect/api_connection/api_connection.dart';

class HealthDepartmentScreen extends StatefulWidget {
  const HealthDepartmentScreen({super.key});

  @override
  State<HealthDepartmentScreen> createState() => _HealthDepartmentScreenState();
}

class _HealthDepartmentScreenState extends State<HealthDepartmentScreen> {
  List<dynamic> laporanKesehatan = []; // Untuk menyimpan data laporan kesehatan

  @override
  void initState() {
    super.initState();
    fetchLaporanKesehatan(); // Ambil data laporan kesehatan saat layar dimuat
  }

  Future<void> fetchLaporanKesehatan() async {
    final url = Uri.parse("${API.hostConnectAdmin}/laporan_medis.php"); // Sesuaikan URL API
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          laporanKesehatan = data['data']; // Menyimpan data ke dalam list
        });
      } else {
        print('Tidak ada data laporan medis');
      }
    } else {
      print("Gagal mengambil data: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DARJOCONNECT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false, // Hilangkan tombol Back
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigasi ke LoginScreen tanpa tombol Back
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Halo Admin Kesehatan', // Menampilkan nama pengguna
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.green.shade100,
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    size: 48,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laporan Terbaru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Informasi tentang laporan medis terkini.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Riwayat Laporan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Menampilkan daftar laporan kesehatan
            Expanded(
              child: laporanKesehatan.isEmpty
                  ? const Center(child: CircularProgressIndicator()) // Menunggu data
                  : ListView.builder(
                      itemCount: laporanKesehatan.length,
                      itemBuilder: (context, index) {
                        final laporan = laporanKesehatan[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.assignment,
                              color: Colors.green,
                            ),
                            title: const Text('Laporan Medis'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(laporan['lokasi_kejadian']), // Lokasi kejadian
                                Text('Tanggal: ${laporan['tanggal_kejadian']}'), 
                                Text('Status: ${laporan['status']}'), // Status laporan
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // Aksi untuk melihat detail laporan
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportHealthDetailScreen(laporan: laporan),
                                ),
                              ).then((value) {
                                if (value == true) {
                                  // Jika kembali dengan nilai true, ambil data terbaru
                                  fetchLaporanKesehatan();
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
