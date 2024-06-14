import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/kendaraan.dart';
import 'database_helper.dart';
import 'list_kendaraan.dart'; // Import halaman daftar kendaraan

class InputKendaraan extends StatefulWidget {
  @override
  _InputKendaraanState createState() => _InputKendaraanState();
}

class _InputKendaraanState extends State<InputKendaraan> {
  final _namaController = TextEditingController();
  String? _jenisKendaraan;
  int? _tahunKendaraan;

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  void _clearInputs() {
    _namaController.clear();
    setState(() {
      _jenisKendaraan = null;
      _tahunKendaraan = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Kendaraan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Kendaraan'),
            ),
            DropdownButton<String>(
              value: _jenisKendaraan,
              hint: const Text('Pilih Jenis Kendaraan'),
              items: <String>['Motor', 'Mobil'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _jenisKendaraan = newValue;
                });
              },
            ),
            DropdownButton<int>(
              value: _tahunKendaraan,
              hint: const Text('Pilih Tahun Kendaraan'),
              items: <int>[2019, 2020, 2021, 2022, 2023, 2024].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _tahunKendaraan = newValue;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_namaController.text.isNotEmpty &&
                    _jenisKendaraan != null &&
                    _tahunKendaraan != null) {
                  final kendaraan = Kendaraan(
                    nama: _namaController.text,
                    jenis: _jenisKendaraan!,
                    tahun: _tahunKendaraan!,
                  );
                  DatabaseHelper.instance
                      .insertKendaraan(kendaraan.toMap())
                      .then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Berhasil menyimpan kendaraan!')));
                    _clearInputs();
                  });
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
