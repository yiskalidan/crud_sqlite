import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'input_transaksi.dart';
import 'model/transaksi.dart';

class ListTransaksi extends StatefulWidget {
  @override
  _ListTransaksiState createState() => _ListTransaksiState();
}

class _ListTransaksiState extends State<ListTransaksi> {
  late Future<List<Transaksi>> _listTransaksi;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _refreshTransaksiList();
  }

  void _refreshTransaksiList() {
    _listTransaksi =
        DatabaseHelper.instance.getAllTransaksi().catchError((error) {
      print('Error: $error');
      return <Transaksi>[]; // Mengembalikan list kosong jika terjadi error
    });
    setState(() {});
  }

  void _deleteSelectedTransaksi() async {
    for (var id in _selectedIds) {
      await DatabaseHelper.instance.deleteTransaksi(id);
    }
    _refreshTransaksiList();
    setState(() {
      _selectedIds.clear();
    });
  }

  void _editTransaksi(Transaksi transaksi) async {
    // Navigasi ke halaman edit transaksi dengan data transaksi yang dipilih
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InputTransaksi(transaksi: transaksi),
      ),
    );

    // Jika hasilnya adalah 'update', maka refresh list transaksi
    if (result == 'update') {
      _refreshTransaksiList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed:
                _selectedIds.isNotEmpty ? _deleteSelectedTransaksi : null,
          ),
        ],
      ),
      body: FutureBuilder<List<Transaksi>>(
        future: _listTransaksi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text(
                    'Gagal mengambil data transaksi. Silakan periksa database.'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Tidak ada transaksi yang tersedia.'));
          } else {
            final List<Transaksi> transaksiList = snapshot.data!;
            return ListView.builder(
              itemCount: transaksiList.length,
              itemBuilder: (context, index) {
                final Transaksi transaksi = transaksiList[index];
                return ListTile(
                  title: Text(transaksi.tanggal),
                  subtitle: Text('Rp. ${transaksi.jumlah}'),
                  leading: Checkbox(
                    value: _selectedIds.contains(transaksi.id),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedIds.add(transaksi.id!);
                        } else {
                          _selectedIds.remove(transaksi.id);
                        }
                      });
                    },
                  ),
                  onTap: () => _editTransaksi(transaksi),
                  onLongPress: () {
                    setState(() {
                      _selectedIds.add(transaksi.id!);
                    });
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
