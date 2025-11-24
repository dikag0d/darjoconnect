import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:darjoconnect/screens/login_screen.dart';
import 'package:darjoconnect/screens/admin_listrik/report_power_detail_screen.dart';
import 'package:darjoconnect/api_connection/api_connection.dart';

class PowerDepartmentScreen extends StatefulWidget {
  const PowerDepartmentScreen({super.key});

  @override
  State<PowerDepartmentScreen> createState() => _PowerDepartmentScreenState();
}

class _PowerDepartmentScreenState extends State<PowerDepartmentScreen> {
  List<dynamic> laporanPemadamanListrik = [];

  @override
  void initState() {
    super.initState();
    fetchLaporanPemadamanListrik();
  }

  Future<void> fetchLaporanPemadamanListrik() async {
    final url = Uri.parse("${API.hostConnectAdmin}/laporan_listrik.php");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          laporanPemadamanListrik = data['data'];
        });
      } else {
        print('Tidak ada data laporan pemadaman listrik');
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
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
              'Halo Admin PLN',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 10, 10, 10),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.yellow.shade700,
                  ),
                  child: const Icon(
                    Icons.electrical_services,
                    size: 48,
                    color: Colors.black,
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
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Informasi tentang laporan pemadaman listrik terkini.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 2, 2, 2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Riwayat Laporan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: laporanPemadamanListrik.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: laporanPemadamanListrik.length,
                      itemBuilder: (context, index) {
                        final laporan = laporanPemadamanListrik[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: Colors.black,
                          child: ListTile(
                            leading: const Icon(
                              Icons.assignment,
                              color: Colors.yellow,
                            ),
                            title: const Text(
                              'Laporan Pemadaman Listrik',
                              style: TextStyle(color: Colors.yellow),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  laporan['lokasi_kejadian'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Tanggal: ${laporan['tanggal_kejadian']}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Status: ${laporan['status']}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.yellow,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ReportPowerDetailScreen(laporan: laporan),
                                ),
                              ).then((value) {
                                if (value == true) {
                                  fetchLaporanPemadamanListrik();
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
