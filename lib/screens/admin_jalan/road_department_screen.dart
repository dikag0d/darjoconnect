import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:darjoconnect/screens/login_screen.dart';
import 'package:darjoconnect/screens/admin_jalan/report_road_detail_screen.dart';
import 'package:darjoconnect/api_connection/api_connection.dart';

class RoadDepartmentScreen extends StatefulWidget {
  const RoadDepartmentScreen({super.key});

  @override
  State<RoadDepartmentScreen> createState() => _RoadDepartmentScreenState();
}

class _RoadDepartmentScreenState extends State<RoadDepartmentScreen> {
  List<dynamic> laporanKerusakanJalan = []; // Untuk menyimpan data laporan kerusakan jalan

  @override
  void initState() {
    super.initState();
    fetchLaporanKerusakanJalan(); // Ambil data laporan kerusakan jalan ketika layar dimuat
  }

  Future<void> fetchLaporanKerusakanJalan() async {
    final url = Uri.parse("${API.hostConnectAdmin}/laporan_jalan.php"); // URL API untuk laporan kerusakan jalan
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          laporanKerusakanJalan = data['data']; // Menyimpan data ke dalam list
        });
      } else {
        print('Tidak ada data laporan kerusakan jalan');
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
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigasi ke LoginScreen
              Navigator.push(
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
              'Halo Admin Jalan', // Menampilkan nama pengguna
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
                    color: Colors.orange.shade100,
                  ),
                   child: const Icon(
        Icons.construction, // Menggunakan ikon konstruksi
        size: 48,
        color: Colors.orange,
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
                        'Informasi tentang laporan kerusakan jalan terkini.',
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
            // Menampilkan daftar laporan kerusakan jalan
            Expanded(
              child: laporanKerusakanJalan.isEmpty
                  ? const Center(child: CircularProgressIndicator()) // Menunggu data
                  : ListView.builder(
                      itemCount: laporanKerusakanJalan.length,
                      itemBuilder: (context, index) {
                        final laporan = laporanKerusakanJalan[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.assignment,
                              color: Colors.orange,
                            ),
                            title: const Text('Laporan Kerusakan Jalan'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(laporan['lokasi_kejadian']), // Lokasi kejadian
                                Text('Tanggal: ${laporan['tanggal_kejadian']}'), // Tanggal kejadian
                                Text('Status: ${laporan['status']}'), // Status laporan
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // Aksi untuk melihat detail laporan
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportRoadDetailScreen(laporan: laporan),
                                ),
                              ).then((value) {
                                if (value == true) {
                                  // Jika kembali dengan nilai true, ambil data terbaru
                                  fetchLaporanKerusakanJalan();
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
