import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:darjoconnect/screens/user/report_screen.dart';
import 'package:darjoconnect/screens/login_screen.dart';
import 'package:darjoconnect/screens/user/history_screen.dart';
import 'package:darjoconnect/screens/user/pengumuman_screen.dart';
import 'package:darjoconnect/api_connection/api_connection.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _userName = 'User'; // Default username
  List<dynamic> _pengumuman = [];

  @override
  void initState() {
    super.initState();
    _getUserName();
    _fetchPengumuman();
  }

  // Function to retrieve username from SharedPreferences
  Future<void> _getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
    });
  }

  // Function to fetch announcements
  Future<void> _fetchPengumuman() async {
    const url = '${API.hostConnectUser}/pengumuman.php';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _pengumuman = jsonDecode(response.body);
        });
      } else {
        print('Failed to load pengumuman, Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching pengumuman: $e');
    }
  }

  // Function to handle logout
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DARJOCONNECT',
          style: GoogleFonts.publicSans(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hai $_userName',
              style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,  // Centering the Row
              children: [
                Container(
                  height: 120, // Perbesar ukuran gambar
                  width: 120, // Perbesar ukuran gambarr
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color.fromARGB(255, 254, 254, 254), // Background putih
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/report.png', // Gambar dari assets
                      width: 120, // Ukuran gambar yang lebih besar
                      height: 120,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Laporkan aduan atau bantuan",
                        style: GoogleFonts.notoSans(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ReportScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text(
                          'Laporkan!',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Pengumuman!',
              style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchPengumuman,
                child: _pengumuman.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        children: _pengumuman
                            .take(2) // Ambil hanya 2 pengumuman pertama
                            .map((item) => NotificationCard(
                                  title: item['judul'],
                                  description: item['deskripsi'],
                                ))
                            .toList(),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16), // Geser tombol ke atas
              child: Align(
                alignment: Alignment.topRight, // Adjust position to be slightly higher
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PengumumanScreen()),
                    );
                  },
                  child: const Text(
                    "Lihat Semua",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center( // Center the button
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryScreen()),
                  );
                },
                child: const Text(
                  'Riwayat Pengaduan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black, // Black background
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String description;

  const NotificationCard({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;

    // Determine the icon and color based on the title
    if (title.contains("Banjir")) {
      iconData = Icons.water_drop;
      iconColor = Colors.blue;
    } else if (title.contains("Kerusakan Jalan")) {
      iconData = Icons.construction;
      iconColor = Colors.orange;
    } else if (title.contains("Kebakaran")) {
      iconData = Icons.fireplace;
      iconColor = Colors.red;
    } else if (title.contains("Pemadaman Listrik")) {
      iconData = Icons.power_off;
      iconColor = Colors.black;
    } else {
      iconData = Icons.info;
      iconColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(iconData, color: iconColor), // Use dynamic icon and color
        title: Text(
          title,
          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description, style: GoogleFonts.notoSans(fontSize: 12)),
      ),
    );
  }
}
