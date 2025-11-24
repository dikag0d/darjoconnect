import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:darjoconnect/api_connection/api_connection.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportFormKesehatan extends StatefulWidget {
  final String reportTitle;
  final int userId;

  const ReportFormKesehatan({
    super.key,
    required this.reportTitle,
    required this.userId,
  });

  @override
  State<ReportFormKesehatan> createState() => _ReportFormKesehatanState();
}

class _ReportFormKesehatanState extends State<ReportFormKesehatan> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final _jalanController = TextEditingController();
  final _desaController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _deskripsiController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Google Map variables
  late GoogleMapController mapController;
  LatLng _selectedLocation = const LatLng(-7.4464, 112.7387);

  // Kondisi Pasien (Checkbox)
  String? _kondisiPasien;
  final List<String> _kondisiOptions = [
    'Ya, darurat.',
    'Tidak, tetapi memerlukan bantuan medis.',
  ];

  String? _riwayatKesehatan;
  final _keteranganPenyakitController = TextEditingController();
  final List<String> _riwayatOptions = [
    'Ya, beri keterangan penyakitnya.',
    'Tidak ada riwayat penyakit.',
  ];

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk mengirim laporan
  Future<void> _submitLaporan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    const url = "${API.hostConnectUser}/laporan_medis.php";
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['id_user'] = widget.userId.toString();
    request.fields['jenis_pengaduan'] = widget.reportTitle;
    request.fields['nama_pelapor'] = _namaController.text;
    request.fields['nomor_telepon'] = _teleponController.text;
    request.fields['lokasi_kejadian'] =
        '${_jalanController.text}, ${_desaController.text}, ${_kecamatanController.text}';
    request.fields['tanggal_kejadian'] = _tanggalController.text;
    request.fields['deskripsi_laporan'] = _deskripsiController.text;
    request.fields['kondisi_pasien'] = _kondisiPasien ?? '';
    request.fields['riwayat_kesehatan'] = _riwayatKesehatan ?? '';
    request.fields['keterangan_penyakit'] = _keteranganPenyakitController.text;
    request.fields['latitude'] = _selectedLocation.latitude.toString();
    request.fields['longitude'] = _selectedLocation.longitude.toString();

    if (_image != null) {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      request.files.add(await http.MultipartFile.fromPath('foto_bukti', _image!.path, filename: fileName));
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengaduan berhasil dikirim')),
        );
        Navigator.pop(context);
      } else {
        print('Status Code: ${response.statusCode}');
        print('Response Body: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim pengaduan: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan jaringan')),
      );
    }
  }

  // Fungsi untuk mengonfigurasi peta
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Fungsi untuk memilih lokasi di peta
  void _selectLocation(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          widget.reportTitle,
          style: GoogleFonts.notoSans(
            color: Colors.white,
            
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _image != null
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : const Icon(Icons.add_a_photo, size: 40),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(_namaController, "Nama Pelapor", "Masukkan nama pelapor"),
              const SizedBox(height: 16),
              _buildTextField(_teleponController, "Nomor Telepon", "Masukkan nomor telepon"),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 14.0,
                  ),
                  onTap: _selectLocation,
                  markers: {
                    Marker(
                      markerId: const MarkerId('selectedLocation'),
                      position: _selectedLocation,
                    ),
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(_jalanController, "Jalan", "Masukkan nama jalan"),
              const SizedBox(height: 16),
              _buildTextField(_desaController, "Desa", "Masukkan nama desa"),
              const SizedBox(height: 16),
              _buildTextField(_kecamatanController, "Kecamatan", "Masukkan nama kecamatan"),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tanggalController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Kejadian',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _tanggalController.text = date.toIso8601String().split('T').first;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal kejadian tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Kondisi Pasien', style: TextStyle(fontSize: 16)),
              ..._kondisiOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _kondisiPasien,
                  onChanged: (value) {
                    setState(() {
                      _kondisiPasien = value;
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 16),
              const Text('Riwayat Kesehatan', style: TextStyle(fontSize: 16)),
              ..._riwayatOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _riwayatKesehatan,
                  onChanged: (value) {
                    setState(() {
                      _riwayatKesehatan = value;
                      if (value == 'Tidak ada riwayat penyakit.') {
                        _keteranganPenyakitController.clear();
                      }
                    });
                  },
                );
              }).toList(),
              if (_riwayatKesehatan == 'Ya, beri keterangan penyakitnya.')
                _buildTextField(
                  _keteranganPenyakitController,
                  "Keterangan Penyakit",
                  "Masukkan riwayat penyakit",
                ),
              const SizedBox(height: 16),
              _buildTextField(_deskripsiController, "Deskripsi Laporan", "Masukkan deskripsi laporan"),
              const SizedBox(height: 16),
             Center(
  child: ElevatedButton(
    onPressed: _submitLaporan,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      textStyle: GoogleFonts.notoSans(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    child: const Text('Kirim Laporan'),
  ),
),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }
}
