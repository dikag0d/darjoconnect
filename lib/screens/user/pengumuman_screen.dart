import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:darjoconnect/api_connection/api_connection.dart';

class PengumumanScreen extends StatefulWidget {
  const PengumumanScreen({super.key});

  @override
  State<PengumumanScreen> createState() => _PengumumanScreenState();
}

class _PengumumanScreenState extends State<PengumumanScreen> {
  List<dynamic> _pengumuman = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPengumuman();
  }

  Future<void> _fetchPengumuman() async {
    const url = '${API.hostConnectUser}/pengumuman.php';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _pengumuman = jsonDecode(response.body);
          _isLoading = false;
          print("Pengumuman Data: $_pengumuman");  // Log data for debugging
        });
      } else {
        throw Exception('Failed to load announcements');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching pengumuman: $e');
    }
  }

  // Function to determine icon and color based on the announcement title
  IconData _getIconBasedOnTitle(String title) {
    if (title.contains("Banjir")) {
      return Icons.water_drop;  // Blue icon for "Banjir"
    } else if (title.contains("Kerusakan Jalan")) {
      return Icons.construction;  // Orange icon for "Kerusakan Jalan"
    } else if (title.contains("Kebakaran")) {
      return Icons.fireplace;  // Red icon for "Kebakaran"
    } else if (title.contains("Pemadaman Listrik")) {
      return Icons.power_off;  // Black icon for "Pemadaman Listrik"
    } else {
      return Icons.info;  // Default icon
    }
  }

  // Function to determine color based on the announcement title
  Color _getIconColorBasedOnTitle(String title) {
    if (title.contains("Banjir")) {
      return Colors.blue;  // Blue color for "Banjir"
    } else if (title.contains("Kerusakan Jalan")) {
      return Colors.orange;  // Orange color for "Kerusakan Jalan"
    } else if (title.contains("Kebakaran")) {
      return Colors.red;  // Red color for "Kebakaran"
    } else if (title.contains("Pemadaman Listrik")) {
      return Colors.black;  // Black color for "Pemadaman Listrik"
    } else {
      return Colors.grey;  // Default color for others
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pengumuman',
          style: GoogleFonts.notoSans(), // Apply the Noto Sans font
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pengumuman.isEmpty
              ? const Center(
                  child: Text('Tidak ada pengumuman saat ini.',
                      style: TextStyle(fontSize: 16)),
                )
              : ListView.builder(
                  itemCount: _pengumuman.length,
                  itemBuilder: (context, index) {
                    final item = _pengumuman[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Icon(
                          _getIconBasedOnTitle(item['judul']),
                          color: _getIconColorBasedOnTitle(item['judul']),
                        ),
                        title: Text(
                          item['judul'],
                          style: GoogleFonts.notoSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          item['deskripsi'],
                          style: GoogleFonts.notoSans(),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
