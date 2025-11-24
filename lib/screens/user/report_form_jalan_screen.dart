import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:darjoconnect/api_connection/api_connection.dart';

class ReportFormJalan extends StatefulWidget {
  final String reportTitle;
  final int userId;

  const ReportFormJalan({
    super.key,
    required this.reportTitle,
    required this.userId,
  });

  @override
  State<ReportFormJalan> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormJalan> {
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

  // Penyebab Kerusakan Jalan (Radio)
  String? _selectedPenyebab;
  final List<String> _penyebabOptions = [
    'Cuaca Ekstrem',
    'Penggunaan Berlebih',
    'Pengerjaan Infrastruktur yang Buruk',
  ];

  // Dampak Kerusakan Jalan (Radio)
  String? _selectedDampak;
  final List<String> _dampakOptions = [
    'Kemacetan Lalu Lintas',
    'Risiko Kecelakaan',
    'Kerusakan Kendaraan',
  ];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitLaporan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    const url = "${API.hostConnectUser}/laporan_jalan.php";
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['id_user'] = widget.userId.toString();
    request.fields['jenis_pengaduan'] = widget.reportTitle;
    request.fields['nama_pelapor'] = _namaController.text;
    request.fields['nomor_telepon'] = _teleponController.text;
    request.fields['lokasi_kejadian'] =
        '${_jalanController.text}, ${_desaController.text}, ${_kecamatanController.text}';
    request.fields['tanggal_kejadian'] = _tanggalController.text;
    request.fields['deskripsi_laporan'] = _deskripsiController.text;
    request.fields['penyebab_kerusakan_jalan'] = _selectedPenyebab ?? '';
    request.fields['dampak_kerusakan_jalan'] = _selectedDampak ?? '';
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

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _selectLocation(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.orange,
        textTheme: GoogleFonts.notoSansTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.reportTitle,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
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
                _buildTextField(_teleponController, "Nomor Telepon", "Masukkan nomor telepon", keyboardType: TextInputType.phone),
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
      // Format tanggal ke format yyyy-MM-dd
      _tanggalController.text = DateFormat('yyyy-MM-dd').format(date);
    });
  } else {
    // Tambahkan handling jika pengguna membatalkan pemilihan tanggal
    print('Tanggal tidak dipilih');
    // Opsional: tampilkan pesan untuk memberi tahu pengguna
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pemilihan tanggal dibatalkan')),
    );
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
                const Text('Penyebab Kerusakan Jalan', style: TextStyle(fontSize: 16)),
                ..._penyebabOptions.map((option) {
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _selectedPenyebab,
                    onChanged: (value) {
                      setState(() {
                        _selectedPenyebab = value;
                      });
                    },
                  );
                }).toList(),
                const SizedBox(height: 16),
                const Text('Dampak Kerusakan Jalan', style: TextStyle(fontSize: 16)),
                ..._dampakOptions.map((option) {
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _selectedDampak,
                    onChanged: (value) {
                      setState(() {
                        _selectedDampak = value;
                      });
                    },
                  );
                }).toList(),
                const SizedBox(height: 16),
                _buildTextField(_deskripsiController, "Deskripsi Kejadian", "Masukkan deskripsi kejadian", maxLines: 5),
                const SizedBox(height: 16),
                ElevatedButton(
                onPressed: _submitLaporan,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.orange, 
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {int? maxLines, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }
}
