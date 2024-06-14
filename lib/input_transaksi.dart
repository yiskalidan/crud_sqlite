import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'model/transaksi.dart';
import 'database_helper.dart';

class InputTransaksi extends StatefulWidget {
  final Transaksi? transaksi;

  InputTransaksi({this.transaksi});

  @override
  _InputTransaksiState createState() => _InputTransaksiState();
}

class _InputTransaksiState extends State<InputTransaksi> {
  final _tanggalController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _biayaSewaController = TextEditingController();
  final _keteranganController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _tanggalController.dispose();
    _jumlahController.dispose();
    _biayaSewaController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  void _submitTransaksi() async {
    DatabaseHelper db = DatabaseHelper.instance;
    try {
      Transaksi newTransaksi = Transaksi(
        tanggal: DateFormat('yyyy-MM-dd').format(_selectedDate),
        jumlah: double.parse(_jumlahController.text),
        biayaSewa: _biayaSewaController.text,
        keterangan: _keteranganController.text,
      );
      await db.insertTransaksi(newTransaksi.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil ditambahkan!'),
          duration: Duration(seconds: 2),
        ),
      );
      // Membersihkan input setelah berhasil menyimpan
      _tanggalController.clear();
      _jumlahController.clear();
      _biayaSewaController.clear();
      _keteranganController.clear();
      _selectedDate = DateTime.now(); // Reset tanggal terpilih
    } catch (e) {
      print('Error: $e');
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text('Terjadi kesalahan saat menyimpan transaksi: $e'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
        _tanggalController.text =
            DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'Tanggal'),
              controller: _tanggalController,
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                _presentDatePicker();
              },
            ),
            TextField(
              controller: _jumlahController,
              decoration: const InputDecoration(labelText: 'Jumlah'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          
            TextField(
              controller: _biayaSewaController,
              decoration: const InputDecoration(labelText: 'biayaSewa'),
                ),
            TextField(
              controller: _keteranganController,
              decoration: const InputDecoration(labelText: 'Keterangan'),
            ),
            ElevatedButton(
              onPressed: _submitTransaksi,
              child: const Text('Simpan Transaksi'),
            ),
          ],
        ),
      ),
    );
  }
}
