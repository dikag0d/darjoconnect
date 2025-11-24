import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; 
import 'package:darjoconnect/api_connection/api_connection.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> _historyFuture;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistory();
  }

  Future<List<Map<String, dynamic>>> _fetchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId'); // Ini bisa mengembalikan null
    
    // Cek jika userId null
    if (userId == null) {
      // Tangani jika userId tidak ditemukan (misalnya, melempar exception atau kembali dengan list kosong)
      throw Exception('User ID tidak ditemukan!'); 
    }

    final url = Uri.parse("${API.hostConnectUser}/riwayat.php?user_id=$userId");

    try {
      final response = await http.get(url);

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        if (response.headers['content-type']?.contains('application/json') == true) {
          final data = jsonDecode(response.body) as List<dynamic>;
          return data.map((item) => item as Map<String, dynamic>).toList();
        } else {
          throw Exception('Respons dari server bukan JSON yang valid');
        }
      } else {
        throw Exception('Gagal mengambil data riwayat. Kode Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Kesalahan saat mengambil atau parsing data: ${e.toString()}");
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Color _getColorByKategori(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'laporan kebakaran':
        return Colors.red;
      case 'laporan banjir':
        return Colors.blue;
      case 'laporan medis':
        return Colors.green;
      case 'laporan kerusakan jalan':
        return Colors.yellow;
      case 'laporan pemadaman listrik':
        return Colors.black;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Pengaduan',
          style: GoogleFonts.notoSans(fontSize: 20),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedCategory = value == "Semua" ? null : value;
              });
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(value: "Semua", child: Text("Semua Kategori")),
                const PopupMenuItem(value: "Laporan Kebakaran", child: Text("Kebakaran")),
                const PopupMenuItem(value: "Laporan Banjir", child: Text("Banjir")),
                const PopupMenuItem(value: "Laporan Medis", child: Text("Medis")),
                const PopupMenuItem(value: "Laporan Kerusakan Jalan", child: Text("Kerusakan Jalan")),
                const PopupMenuItem(value: "Laporan Pemadaman Listrik", child: Text("Pemadaman Listrik")),
              ];
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(  
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat data: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada riwayat pengaduan.'));
          }

          final riwayat = snapshot.data!;
          final filteredRiwayat = _selectedCategory == null
              ? riwayat
              : riwayat
                  .where((item) => item['kategori'].toString().toLowerCase() == _selectedCategory!.toLowerCase())
                  .toList();

          if (filteredRiwayat.isEmpty) {
            return const Center(child: Text('Tidak ada laporan untuk kategori ini.'));
          }

          return ListView.builder(
            itemCount: filteredRiwayat.length,
            itemBuilder: (context, index) {
              final laporan = filteredRiwayat[index];
              final color = _getColorByKategori(laporan['kategori']);

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color,
                    child: const Icon(Icons.report, color: Colors.white),
                  ),
                  title: Text(
                    laporan['kategori'],
                    style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tanggal: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(laporan['tanggal_kejadian']))}'),
                      Text('Lokasi: ${laporan['lokasi_kejadian']}'),
                      Text('Status: ${laporan['status']}'),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
