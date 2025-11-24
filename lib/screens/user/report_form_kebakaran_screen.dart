import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:darjoconnect/api_connection/api_connection.dart';

class ReportFormKebakaran extends StatefulWidget {
  final String reportTitle;
  final int userId;

  const ReportFormKebakaran({
    super.key,
    required this.reportTitle,
    required this.userId,
  });

  @override
  State<ReportFormKebakaran> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormKebakaran> {
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

  // Penyebab Kebakaran (RadioListTile)
  String? _penyebabKebakaran;
  final List<String> _penyebabOptions = [
    'Peralatan listrik rusak atau hubungan pendek',
    'Kelalaian manusia (membakar sampah, api terbuka)',
    'Cuaca ekstrem (panas terik, petir)',
  ];

  // Dampak Kebakaran (Checkbox)
  final List<String> _dampakKebakaran = [];

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

    const url = "${API.hostConnectUser}/laporan_kebakaran.php";
    final request = http.MultipartRequest('POST', Uri.parse(url));

    request.fields['id_user'] = widget.userId.toString();
    request.fields['jenis_pengaduan'] = widget.reportTitle;
    request.fields['nama_pelapor'] = _namaController.text;
    request.fields['nomor_telepon'] = _teleponController.text;
    request.fields['lokasi_kejadian'] =
        '${_jalanController.text}, ${_desaController.text}, ${_kecamatanController.text}';
    request.fields['tanggal_kejadian'] = _tanggalController.text;
    request.fields['deskripsi_laporan'] = _deskripsiController.text;
    request.fields['penyebab_kebakaran'] = _penyebabKebakaran ?? '';
    request.fields['dampak_kebakaran'] = _dampakKebakaran.join(", ");
    request.fields['latitude'] = _selectedLocation.latitude.toString();
    request.fields['longitude'] = _selectedLocation.longitude.toString();

    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath('foto_bukti', _image!.path));
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

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _tanggalController.text = "${pickedDate.toLocal()}".split(' ')[0]; // Format tanggal yang dipilih
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.reportTitle,
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.red,
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
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pelapor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama pelapor tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _teleponController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  return null;
                },
              ),
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
              TextFormField(
                controller: _jalanController,
                decoration: const InputDecoration(
                  labelText: 'Jalan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jalan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _desaController,
                decoration: const InputDecoration(
                  labelText: 'Desa',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Desa tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kecamatanController,
                decoration: const InputDecoration(
                  labelText: 'Kecamatan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kecamatan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Input tanggal
              TextFormField(
                controller: _tanggalController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Kejadian',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal kejadian tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  const Text('Penyebab Kebakaran', style: TextStyle(fontSize: 16)),
                  ..._penyebabOptions.map((penyebab) {
                    return RadioListTile<String>(
                      title: Text(penyebab),
                      value: penyebab,
                      groupValue: _penyebabKebakaran,
                      onChanged: (value) {
                        setState(() {
                          _penyebabKebakaran = value;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dampak Kebakaran', style: TextStyle(fontSize: 16)),
                  CheckboxListTile(
                    title: const Text('Rumah rusak'),
                    value: _dampakKebakaran.contains('Rumah rusak'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _dampakKebakaran.add('Rumah rusak');
                        } else {
                          _dampakKebakaran.remove('Rumah rusak');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Fasilitas umum rusak'),
                    value: _dampakKebakaran.contains('Fasilitas umum rusak'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _dampakKebakaran.add('Fasilitas umum rusak');
                        } else {
                          _dampakKebakaran.remove('Fasilitas umum rusak');
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Laporan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi laporan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitLaporan,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red, 
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
}
