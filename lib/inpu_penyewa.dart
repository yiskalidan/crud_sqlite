import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/penyewa.dart';
import 'model/kendaraan.dart';
import 'database_helper.dart';

class InputPenyewa extends StatefulWidget {
  @override
  _InputPenyewaState createState() => _InputPenyewaState();
}

class _InputPenyewaState extends State<InputPenyewa> {
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _nomorTeleponController = TextEditingController();
  int? _selectedKendaraanId;

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _nomorTeleponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Penyewa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: _alamatController,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
            TextField(
              controller: _nomorTeleponController,
              decoration: const InputDecoration(labelText: 'Nomor Telepon'),
            ),
            FutureBuilder<List<Kendaraan>>(
              future: DatabaseHelper.instance.getKendaraan(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Text('Tidak ada data kendaraan');
                }
                return DropdownButton<int>(
                  value: _selectedKendaraanId,
                  hint: const Text('Pilih Kendaraan'),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedKendaraanId = newValue;
                    });
                  },
                  items: snapshot.data!
                      .map<DropdownMenuItem<int>>((Kendaraan kendaraan) {
                    return DropdownMenuItem<int>(
                      value: kendaraan.id,
                      child: Text('${kendaraan.nama} (${kendaraan.jenis})'),
                    );
                  }).toList(),
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedKendaraanId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text('Silakan pilih kendaraan terlebih dahulu.')));
                  return;
                }
                final penyewa = Penyewa(
                  nama: _namaController.text,
                  alamat: _alamatController.text,
                  nomorTelepon: _nomorTeleponController.text,
                  kendaraanId: _selectedKendaraanId,
                );
                DatabaseHelper.instance.insertPenyewa({
                  'nama': penyewa.nama,
                  'alamat': penyewa.alamat,
                  'nomorTelepon': penyewa.nomorTelepon,
                  'kendaraan_id': penyewa.kendaraanId
                }).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Berhasil menyewa!')));
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${error.toString()}')));
                });
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
