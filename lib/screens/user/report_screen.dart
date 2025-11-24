import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:darjoconnect/screens/user/report_form_kebakaran_screen.dart';
import 'package:darjoconnect/screens/user/report_form_banjir_screen.dart';
import 'package:darjoconnect/screens/user/report_form_jalan_screen.dart';
import 'package:darjoconnect/screens/user/report_form_listrik_screen.dart';
import 'package:darjoconnect/screens/user/report_form_kesehatan_screen.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  Future<int?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId'); // Ambil ID user dari SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> reports = [
      {'title': 'Laporan Kerusakan Jalan', 'image': 'assets/images/road.png'},
      {'title': 'Laporan Kebakaran', 'image': 'assets/images/fire.png'},
      {'title': 'Laporan Medis', 'image': 'assets/images/medical.png'},
      {'title': 'Laporan Pemadaman Listrik', 'image': 'assets/images/electricity.png'},
      {'title': 'Laporan Banjir', 'image': 'assets/images/flood.png'},
    ];

    return Scaffold(
      appBar: AppBar(
  title: Text(
    'Laporan Pengaduan',
    style: GoogleFonts.notoSans( // Menggunakan font Noto Sans untuk AppBar
    
      fontSize: 20, // Ukuran font untuk judul AppBar
    ),
  ),
),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
  "Laporan jika terjadi keadaan darurat. Instansi terkait akan segera sampai di sana",
  style: GoogleFonts.notoSans( // Menggunakan font Noto Sans untuk teks penjelasan
    fontSize: 16,
    color: Colors.grey,
  ),
),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 12), // Jarak antar kartu
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Membuat sudut kartu melengkung
                    ),
                    elevation: 4, // Menambahkan bayangan pada kartu
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16), // Padding di dalam kartu
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8), // Membuat sudut gambar melengkung
                        child: Image.asset(
                          report['image']!,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover, // Memastikan gambar sesuai dengan ukuran
                        ),
                      ),
                      title: Text(
                        report['title']!,
                        style: GoogleFonts.notoSans( // Menggunakan Noto Serif
                          fontWeight: FontWeight.bold,
                          fontSize: 15, // Ukuran font yang lebih besar
                        ),
                      ),
                      onTap: () async {
                        final userId = await _getUserId(); // Ambil ID user

                        if (userId != null) {
                          // Navigasi ke form laporan yang sesuai berdasarkan judul laporan
                          Widget nextScreen;
                          switch (report['title']) {
                            case 'Laporan Kerusakan Jalan':
                              nextScreen = ReportFormJalan(
                                reportTitle: report['title']!,
                                userId: userId,
                              );
                              break;
                            case 'Laporan Kebakaran':
                              nextScreen = ReportFormKebakaran(
                                reportTitle: report['title']!,
                                userId: userId,
                              );
                              break;
                            case 'Laporan Medis':
                              nextScreen = ReportFormKesehatan(
                                reportTitle: report['title']!,
                                userId: userId,
                              );
                              break;
                            case 'Laporan Pemadaman Listrik':
                              nextScreen = ReportFormListrik(
                                reportTitle: report['title']!,
                                userId: userId,
                              );
                              break;
                            case 'Laporan Banjir':
                              nextScreen = ReportFormBanjir(
                                reportTitle: report['title']!,
                                userId: userId,
                              );
                              break;
                            default:
                              nextScreen = Container(); // Fallback jika laporan tidak dikenali
                          }

                          // Navigasi ke halaman form yang sesuai
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => nextScreen,
                            ),
                          );
                        } else {
                          // Jika ID user tidak ditemukan, arahkan ke login
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Harap login terlebih dahulu')),
                          );
                          Navigator.pushNamed(context, '/login');
                        }
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