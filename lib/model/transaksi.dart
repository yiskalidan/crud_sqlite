class Transaksi {
  final int? id;
  final String tanggal;
  final double jumlah;
  final String biayaSewa;
  final String keterangan;

  Transaksi(
      {this.id,
      required this.tanggal,
      required this.jumlah,
      required this.biayaSewa,
      required this.keterangan});

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('id') ||
        !map.containsKey('tanggal') ||
        !map.containsKey('jumlah') ||
         !map.containsKey('biayaSewa') ||
        !map.containsKey('keterangan')) {
      throw Exception(
          'Kunci tidak ditemukan dalam peta saat mencoba membuat Transaksi dari Map');
    }
    return Transaksi(
      id: map['id'],
      tanggal: map['tanggal'],
      jumlah: map['jumlah'],
      biayaSewa: map['biayaSewa'],
      keterangan: map['keterangan'],
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'tanggal': tanggal,
      'jumlah': jumlah,
      'biayaSewa':biayaSewa,
      'keterangan': keterangan,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
