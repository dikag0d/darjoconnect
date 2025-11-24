import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:darjoconnect/api_connection/api_connection.dart';

class ReportHealthDetailScreen extends StatefulWidget {
  final Map<String, dynamic> laporan;

  const ReportHealthDetailScreen({super.key, required this.laporan});

  @override
  State<ReportHealthDetailScreen> createState() => _ReportHealthDetailScreenState();
}

class _ReportHealthDetailScreenState extends State<ReportHealthDetailScreen> {
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.laporan['status']; // Menginisialisasi status awal
  }

  Future<void> updateStatus() async {
    final url = Uri.parse("${API.hostConnectAdmin}/update_status.php");
    final response = await http.post(url, body: {
      'id_laporan': widget.laporan['id'].toString(),
      'status': selectedStatus!,
      'tipe_laporan': 'kesehatan',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status laporan berhasil diperbarui')),
        );
        Navigator.pop(context, true); // Kembali ke halaman sebelumnya
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui status')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan jaringan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng location = LatLng(
      double.tryParse(widget.laporan['latitude'].toString()) ?? 0.0,
      double.tryParse(widget.laporan['longitude'].toString()) ?? 0.0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Laporan Kesehatan',
          style: GoogleFonts.publicSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Laporan Kesehatan',
              style: GoogleFonts.notoSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildDetailCard(
              title: 'Nama Pelapor',
              content: widget.laporan['nama_pelapor'] ?? '-',
            ),
            _buildDetailCard(
              title: 'Nomor Telepon',
              content: widget.laporan['nomor_telepon'] ?? '-',
            ),
            _buildDetailCard(
              title: 'Lokasi Kejadian',
              content: widget.laporan['lokasi_kejadian'] ?? '-',
            ),
            _buildDetailCard(
              title: 'Tanggal Kejadian',
              content: widget.laporan['tanggal_kejadian'] ?? '-',
            ),
            _buildDetailCard(
              title: 'Kondisi Pasien',
              content: widget.laporan['kondisi_pasien'] ?? '-',
            ),
            _buildDetailCard(
              title: 'Riwayat Kesehatan',
              content: widget.laporan['riwayat_kesehatan'] ?? '-',
            ),
            if (widget.laporan['riwayat_kesehatan'] == 'Ya, beri keterangan penyakitnya.')
              _buildDetailCard(
                title: 'Keterangan Penyakit',
                content: widget.laporan['keterangan_penyakit'] ?? '-',
              ),

            const SizedBox(height: 16),
            const Text(
              'Status Laporan:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedStatus,
              items: [
                'Laporan Dikirim',
                'Laporan Palsu',
                'Laporan Diproses',
                'Laporan Selesai Diproses',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedStatus = newValue;
                });
              },
            ),

            const SizedBox(height: 16),

            if (widget.laporan['image_url'] != null && widget.laporan['image_url'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Foto Bukti:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Image.network(
                    '${API.hostConnectUser}/${widget.laporan['image_url']}',
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'Gagal memuat foto.',
                        style: TextStyle(color: Colors.red),
                      );
                    },
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ],
              ),

            const SizedBox(height: 16),
            const Text(
              'Lokasi di Peta:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: location,
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('reportLocation'),
                    position: location,
                  ),
                },
                onMapCreated: (GoogleMapController controller) {},
              ),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: updateStatus,
              child: const Text(
                'Update Status',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({required String title, required String content}) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                content,
                style: GoogleFonts.notoSans(fontSize: 14),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
