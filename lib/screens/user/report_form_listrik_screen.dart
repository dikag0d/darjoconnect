import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:darjoconnect/api_connection/api_connection.dart';

class ReportFormListrik extends StatefulWidget {
  final String reportTitle;
  final int userId;

  const ReportFormListrik({
    super.key,
    required this.reportTitle,
    required this.userId,
  });

  @override
  State<ReportFormListrik> createState() => _ReportFormListrikState();
}

class _ReportFormListrikState extends State<ReportFormListrik> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();

  final _tanggalController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _jalanController = TextEditingController();  // Controller untuk jalan
  final _desaController = TextEditingController();  // Controller untuk desa
  final _kecamatanController = TextEditingController();  // Controller untuk kecamatan
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Google Map variables
  late GoogleMapController mapController;
  LatLng _selectedLocation = const LatLng(-7.4464, 112.7387);

  // Waktu Pemadaman (Radio Button)
  String? _waktuPemadaman;
  final List<String> _waktuPemadamanOptions = [
    '1-3 Jam',
    '4-7 Jam',
    '7-10 Jam',
  ];

  // Skala Pemadaman (Radio Button)
  String? _skalaPemadaman;
  final List<String> _skalaPemadamanOptions = [
    'Pemadaman total di seluruh area.',
    'Hanya beberapa rumah yang terputus aliran listrik.',
  ];

  // Penyebab (Radio Button)
  String? _penyebab;
  final List<String> _penyebabOptions = [
    'Kabel listrik terputus di jalan utama.',
    'Tiang listrik roboh di dekat rumah saya.',
    'Ada bau terbakar di kabel listrik yang terjuntai.',
    'Lainnya (isi di deskripsi)',
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

    // Kombinasikan data lokasi dari tiga controller
    String lokasiKejadian = '${_jalanController.text}, ${_desaController.text}, ${_kecamatanController.text}';

    const url = "${API.hostConnectUser}/laporan_listrik.php";
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['id_user'] = widget.userId.toString();
    request.fields['jenis_pengaduan'] = widget.reportTitle;
    request.fields['nama_pelapor'] = _namaController.text;
    request.fields['nomor_telepon'] = _teleponController.text;
    request.fields['lokasi_kejadian'] = lokasiKejadian;  // Menggunakan lokasi gabungan
    request.fields['tanggal_kejadian'] = _tanggalController.text;
    request.fields['deskripsi_laporan'] = _deskripsiController.text;
    request.fields['waktu_pemadaman'] = _waktuPemadaman ?? '';
    request.fields['skala_pemadaman'] = _skalaPemadaman ?? '';
    request.fields['penyebab'] = _penyebab ?? '';
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
        backgroundColor: Colors.black,
        title: Text(widget.reportTitle, style: GoogleFonts.notoSans(color: Colors.white)),
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
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _image != null
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : const Icon(Icons.add_a_photo, size: 40),
                ),
              ),
              const SizedBox(height: 16),

              // Input Teks
              _buildTextField(_namaController, "Nama Pelapor", "Masukkan nama pelapor"),
              const SizedBox(height: 16),
              _buildTextField(_teleponController, "Nomor Telepon", "Masukkan nomor telepon"),

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
              _buildTextField(_jalanController, "Nama Jalan", "Masukkan nama jalan"),  // Input jalan
              const SizedBox(height: 16),
              _buildTextField(_desaController, "Desa/Kelurahan", "Masukkan nama desa"),  // Input desa
              const SizedBox(height: 16),
              _buildTextField(_kecamatanController, "Kecamatan", "Masukkan nama kecamatan"),  // Input kecamatan
              const SizedBox(height: 16),

              // Tanggal Kejadian
              TextFormField(
                controller: _tanggalController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Kejadian',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                // Saat memilih tanggal
onTap: () async {
  final date = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  if (date != null) {
    setState(() {
      // Format menjadi yyyy-MM-dd untuk format yang lebih umum
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
              ),
              const SizedBox(height: 16),

              // Waktu Pemadaman
              const Text('Waktu Pemadaman', style: TextStyle(fontSize: 16)),
              ..._waktuPemadamanOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(option, style: GoogleFonts.notoSans()),
                  value: option,
                  groupValue: _waktuPemadaman,
                  onChanged: (value) {
                    setState(() {
                      _waktuPemadaman = value;
                    });
                  },
                );
              }).toList(),

              // Skala Pemadaman
              const Text('Skala Pemadaman', style: TextStyle(fontSize: 16)),
              ..._skalaPemadamanOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(option, style: GoogleFonts.notoSans()),
                  value: option,
                  groupValue: _skalaPemadaman,
                  onChanged: (value) {
                    setState(() {
                      _skalaPemadaman = value;
                    });
                  },
                );
              }).toList(),

              // Penyebab
              const Text('Penyebab', style: TextStyle(fontSize: 16)),
              ..._penyebabOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(option, style: GoogleFonts.notoSans()),
                  value: option,
                  groupValue: _penyebab,
                  onChanged: (value) {
                    setState(() {
                      _penyebab = value;
                    });
                  },
                );
              }).toList(),

              const SizedBox(height: 16),

              // Deskripsi Laporan
              TextFormField(
                controller: _deskripsiController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Laporan',
                  hintText: 'Masukkan deskripsi laporan',
                  border: OutlineInputBorder(),
                  hintStyle: GoogleFonts.notoSans(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tombol Kirim
              ElevatedButton(
                onPressed: _submitLaporan,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black, 
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

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: GoogleFonts.notoSans(),
        labelStyle: GoogleFonts.notoSans(),
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
