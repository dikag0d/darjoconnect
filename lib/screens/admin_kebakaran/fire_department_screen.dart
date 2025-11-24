import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:darjoconnect/screens/login_screen.dart';
import 'package:darjoconnect/screens/admin_kebakaran/report_fire_detail_screen.dart';
import 'package:darjoconnect/api_connection/api_connection.dart';

class FireDepartmentScreen extends StatefulWidget {
  const FireDepartmentScreen({super.key});

  @override
  State<FireDepartmentScreen> createState() => _FireDepartmentScreenState();
}

class _FireDepartmentScreenState extends State<FireDepartmentScreen> {
  List<dynamic> laporanKebakaran = []; // Untuk menyimpan data laporan kebakaran

  @override
  void initState() {
    super.initState();
    fetchLaporanKebakaran(); // Ambil data laporan kebakaran ketika layar dimuat
  }

  Future<void> fetchLaporanKebakaran() async {
    final url = Uri.parse("${API.hostConnectAdmin}/laporan_kebakaran.php"); // Ganti dengan URL API yang sesuai
    final response = await http.get(url);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}'); // Menampilkan respons mentah untuk debugging

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            laporanKebakaran = data['data']; // Menyimpan data ke dalam list
          });
        } else {
          print('Tidak ada data laporan kebakaran');
        }
      } catch (e) {
        print('Error parsing JSON: $e');
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
              'Halo Pemadam Kebakaran', // Menampilkan nama pengguna
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.red,
                  ),
                  child: const Icon(
                    Icons.fire_hydrant,
                    size: 48,
                    color: Colors.white,
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
                        'Informasi tentang laporan kebakaran terkini.',
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
            // Menampilkan daftar laporan kebakaran
            Expanded(
              child: laporanKebakaran.isEmpty
                  ? const Center(child: CircularProgressIndicator()) // Menunggu data
                  : ListView.builder(
                      itemCount: laporanKebakaran.length,
                      itemBuilder: (context, index) {
                        final laporan = laporanKebakaran[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.assignment,
                              color: Colors.red,
                            ),
                            title: const Text('Laporan Kebakaran'),
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
                                  builder: (context) =>
                                      ReportFireDetailScreen(laporan: laporan),
                                ),
                              ).then((value) {
                                if (value == true) {
                                  // Jika kembali dengan nilai true, ambil data terbaru
                                  fetchLaporanKebakaran();
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
