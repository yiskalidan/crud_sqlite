import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'model/kendaraan.dart';
import 'model/penyewa.dart';
import 'input_kendaraan.dart';

class ListKendaraan extends StatefulWidget {
  @override
  _ListKendaraanState createState() => _ListKendaraanState();
}

class _ListKendaraanState extends State<ListKendaraan> {
  late Future<List<Kendaraan>> _listKendaraan;
  List<int> _selectedKendaraans = [];
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    _refreshKendaraanList();
  }

  void _refreshKendaraanList() {
    _listKendaraan = DatabaseHelper.instance.getKendaraan();
    setState(() {}); // Menambahkan setState untuk memperbarui UI
  }

  void _toggleSelectingMode() {
    setState(() {
      _isSelecting = !_isSelecting;
      if (!_isSelecting) {
        _selectedKendaraans.clear();
      }
    });
  }

  void _selectAllKendaraans(List<Kendaraan> kendaraans) {
    setState(() {
      if (_selectedKendaraans.length == kendaraans.length) {
        _selectedKendaraans.clear();
      } else {
        _selectedKendaraans =
            kendaraans.map((kendaraan) => kendaraan.id!).toList();
      }
    });
  }

  void _deleteSelectedKendaraans() {
    _selectedKendaraans.forEach((id) {
      DatabaseHelper.instance.deleteKendaraan(id).then((_) {
        _refreshKendaraanList();
        if (_selectedKendaraans.isEmpty) {
          _toggleSelectingMode();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kendaraan'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InputKendaraan()),
              ).then((_) => _refreshKendaraanList());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed:
                _isSelecting ? _deleteSelectedKendaraans : _toggleSelectingMode,
          ),
        ],
      ),
      body: FutureBuilder<List<Kendaraan>>(
        future: _listKendaraan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final kendaraans = snapshot.data!;
            return Column(
              children: [
                if (_isSelecting)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => _selectAllKendaraans(kendaraans),
                        child: Text(
                            _selectedKendaraans.length == kendaraans.length
                                ? 'Batalkan Pilihan'
                                : 'Pilih Semua'),
                      ),
                      TextButton(
                        onPressed: _deleteSelectedKendaraans,
                        child: const Text('Hapus Terpilih'),
                      ),
                    ],
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: kendaraans.length,
                    itemBuilder: (context, index) {
                      final kendaraan = kendaraans[index];
                      return ListTile(
                        title: Text(kendaraan.nama),
                        subtitle: FutureBuilder<Penyewa?>(
                          future: DatabaseHelper.instance
                              .getPenyewaByKendaraanId(kendaraan.id!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text('Memuat penyewa...');
                            } else if (snapshot.hasData) {
                              final penyewa = snapshot.data;
                              return Text(
                                  'Disewa oleh ${penyewa?.nama ?? 'Tidak diketahui'}');
                            } else {
                              return const Text('Belum disewa');
                            }
                          },
                        ),
                        trailing: _isSelecting
                            ? Checkbox(
                                value:
                                    _selectedKendaraans.contains(kendaraan.id),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedKendaraans.add(kendaraan.id!);
                                    } else {
                                      _selectedKendaraans.remove(kendaraan.id);
                                    }
                                  });
                                },
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
