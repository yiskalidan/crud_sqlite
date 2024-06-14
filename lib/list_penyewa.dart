import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'model/penyewa.dart';
import 'model/kendaraan.dart'; // Import model kendaraan

class ListPenyewa extends StatefulWidget {
  @override
  _ListPenyewaState createState() => _ListPenyewaState();
}

class _ListPenyewaState extends State<ListPenyewa> {
  late Future<List<Penyewa>> _listPenyewa;
  List<int> _selectedPenyewas = [];
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    _refreshPenyewaList();
  }

  void _refreshPenyewaList() {
    _listPenyewa = DatabaseHelper.instance.getPenyewa();
    setState(() {});
  }

  void _toggleSelectingMode() {
    setState(() {
      _isSelecting = !_isSelecting;
      if (!_isSelecting) {
        _selectedPenyewas.clear();
      }
    });
  }

  void _deleteSelectedPenyewas() {
    _selectedPenyewas.forEach((id) {
      DatabaseHelper.instance.deletePenyewa(id).then((_) {
        _refreshPenyewaList();
        if (_selectedPenyewas.isEmpty) {
          _toggleSelectingMode();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Penyewa'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed:
                _isSelecting ? _deleteSelectedPenyewas : _toggleSelectingMode,
          ),
        ],
      ),
      body: FutureBuilder<List<Penyewa>>(
        future: _listPenyewa,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Tidak ada data penyewa.'));
          } else {
            final penyewas = snapshot.data!;
            return ListView.builder(
              itemCount: penyewas.length,
              itemBuilder: (context, index) {
                final penyewa = penyewas[index];
                return ListTile(
                  title: Text(penyewa.nama),
                  subtitle: FutureBuilder<Kendaraan?>(
                    future: penyewa.kendaraanId != null
                        ? DatabaseHelper.instance
                            .getKendaraanById(penyewa.kendaraanId!)
                        : Future.value(null),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Memuat kendaraan...');
                      } else if (snapshot.hasData) {
                        return Text('Kendaraan: ${snapshot.data!.nama}');
                      } else {
                        return const Text('Kendaraan tidak diketahui');
                      }
                    },
                  ),
                  trailing: _isSelecting
                      ? Checkbox(
                          value: _selectedPenyewas.contains(penyewa.id),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                if (penyewa.id != null) {
                                  _selectedPenyewas.add(penyewa.id!);
                                }
                              } else {
                                if (penyewa.id != null) {
                                  _selectedPenyewas.remove(penyewa.id!);
                                }
                              }
                            });
                          },
                        )
                      : null,
                );
              },
            );
          }
        },
      ),
    );
  }
}
