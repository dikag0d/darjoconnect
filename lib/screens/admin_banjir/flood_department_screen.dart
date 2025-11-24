import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:darjoconnect/screens/login_screen.dart';
import 'package:darjoconnect/screens/admin_banjir/report_flood_detail_screen.dart';
import 'package:darjoconnect/api_connection/api_connection.dart';

class FloodDepartmentScreen extends StatefulWidget {
  const FloodDepartmentScreen({super.key});

  @override
  State<FloodDepartmentScreen> createState() => _FloodDepartmentScreenState();
}

class _FloodDepartmentScreenState extends State<FloodDepartmentScreen> {
  List<dynamic> laporanBanjir = []; // Untuk menyimpan data laporan banjir

  @override
  void initState() {
    super.initState();
    fetchLaporanBanjir(); // Ambil data laporan banjir ketika layar dimuat
  }

  Future<void> fetchLaporanBanjir() async {
    final url = Uri.parse("${API.hostConnectAdmin}/laporan_banjir.php"); // Ganti dengan URL API yang sesuai
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          laporanBanjir = data['data']; // Menyimpan data ke dalam list
        });
      } else {
        print('Tidak ada data laporan banjir');
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
              'Halo Admin Banjir', // Menampilkan nama pengguna
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
                    color: Colors.blue.shade100,
                  ),
                  child: const Icon(
                    Icons.water_damage,
                    size: 48,
                    color: Colors.blue,
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
                        'Informasi tentang laporan banjir terkini.',
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
            // Menampilkan daftar laporan banjir
            Expanded(
              child: laporanBanjir.isEmpty
                  ? const Center(child: CircularProgressIndicator()) // Menunggu data
                  : ListView.builder(
                      itemCount: laporanBanjir.length,
                      itemBuilder: (context, index) {
                        final laporan = laporanBanjir[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.assignment,
                              color: Colors.blue,
                            ),
                            title: const Text('Laporan Banjir'),
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
                                  builder: (context) => ReportFloodDetailScreen(laporan: laporan),
                                ),
                              ).then((value) {
                                if (value == true) {
                                  // Jika kembali dengan nilai true, ambil data terbaru
                                  fetchLaporanBanjir();
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
