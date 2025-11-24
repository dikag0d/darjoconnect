import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:darjoconnect/api_connection/api_connection.dart';
import 'package:intl/intl.dart';  // Pastikan import intl untuk format tanggal
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class ReportFormBanjir extends StatefulWidget {
  final String reportTitle;
  final int userId;

  const ReportFormBanjir({
    super.key,
    required this.reportTitle,
    required this.userId,
  });

  @override
  State<ReportFormBanjir> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormBanjir> {
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

  // Penyebab Banjir (Checkbox)
  final List<String> _penyebabBanjir = [];
  final List<String> _penyebabOptions = [
    'Saluran yang tersumbat',
    'Sungai yang meluap di sekitar lokasi',
    'Tanggul jebol di sekitar lokasi',
  ];

  // Dampak Banjir (Checkbox)
  final List<String> _dampakBanjir = [];
  final List<String> _dampakOptions = [
    'Beberapa rumah terendam banjir',
    'Ada warga yang memerlukan evakuasi',
    'Fasilitas umum terendam banjir',
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
    
    const url = "${API.hostConnectUser}/laporan_banjir.php";
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['id_user'] = widget.userId.toString();
    request.fields['jenis_pengaduan'] = widget.reportTitle;
    request.fields['nama_pelapor'] = _namaController.text;
    request.fields['nomor_telepon'] = _teleponController.text;
    request.fields['lokasi_kejadian'] =
        '${_jalanController.text}, ${_desaController.text}, ${_kecamatanController.text}';
    request.fields['tanggal_kejadian'] = _tanggalController.text;
    request.fields['deskripsi_laporan'] = _deskripsiController.text;
    request.fields['penyebab_banjir'] = _penyebabBanjir.join(", ");
    request.fields['dampak_banjir'] = _dampakBanjir.join(", ");
    request.fields['latitude'] = _selectedLocation.latitude.toString();
    request.fields['longitude'] = _selectedLocation.longitude.toString();
   
    // Menambahkan file gambar dengan nama sesuai ID atau timestamp
    if (_image != null) {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';  // Nama file berdasarkan timestamp
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
        title: Text(widget.reportTitle, style: GoogleFonts.notoSans(color: Colors.white)),  // Menambahkan font Noto Sans
        backgroundColor: Colors.blue,  // Setel warna tema biru untuk AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Input Gambar
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _image != null
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : const Icon(Icons.add_a_photo, size: 40, color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),

              // Input Teks
              _buildTextField(_namaController, "Nama Pelapor", "Masukkan nama pelapor"),
              const SizedBox(height: 16),
              _buildTextField(_teleponController, "Nomor Telepon", "Masukkan nomor telepon"),
              const SizedBox(height: 16),
              // Peta untuk memilih lokasi
              SizedBox(
                height: 300,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,  // Default lokasi Kabupaten Sidoarjo
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
              // Tanggal Kejadian
              TextFormField(
                controller: _tanggalController,
                decoration: InputDecoration(
                  labelText: 'Tanggal Kejadian',
                  labelStyle: GoogleFonts.notoSans(), // Menggunakan font Noto Sans di label
                  border: const OutlineInputBorder(),
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
        // Format tanggal ke format yyyy-MM-dd
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(date);
      });
    }
  },
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Tanggal kejadian tidak boleh kosong';
    }
    return null;
  },
  style: GoogleFonts.notoSans(), // Menggunakan font Noto Sans di input
),
              const SizedBox(height: 16),

              // Penyebab Banjir
              Text('Penyebab Banjir', style: GoogleFonts.notoSans()),  // Menambahkan font Noto Sans
              ..._penyebabOptions.map((option) {
                return CheckboxListTile(
                  title: Text(option, style: GoogleFonts.notoSans()), // Menambahkan font Noto Sans
                  value: _penyebabBanjir.contains(option),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _penyebabBanjir.add(option);
                      } else {
                        _penyebabBanjir.remove(option);
                      }
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 16),

              // Dampak Banjir
             Text('Dampak Banjir', style: GoogleFonts.notoSans())
, // Menambahkan font Noto Sans
              ..._dampakOptions.map((option) {
                return CheckboxListTile(
                  title: Text(option, style: GoogleFonts.notoSans()), // Menambahkan font Noto Sans
                  value: _dampakBanjir.contains(option),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _dampakBanjir.add(option);
                      } else {
                        _dampakBanjir.remove(option);
                      }
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 16),
              _buildTextField(_deskripsiController, "Deskripsi Laporan", "Masukkan deskripsi laporan"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitLaporan,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue, 
    foregroundColor: Colors.white, 
    textStyle: GoogleFonts.notoSans(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  ),
  child: const Text('Kirim Laporan'),
),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build text fields
  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.notoSans(), // Menambahkan font Noto Sans
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
      style: GoogleFonts.notoSans(), // Menambahkan font Noto Sans di input
    );
  }
}
