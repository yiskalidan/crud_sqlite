class Penyewa {
  final int? id;
  String nama;
  String alamat;
  String nomorTelepon;
  int? kendaraanId; // Tambahkan properti kendaraanId

  Penyewa(
      {this.id,
      required this.nama,
      required this.alamat,
      required this.nomorTelepon,
      this.kendaraanId // Tambahkan ini di konstruktor
      });

  factory Penyewa.fromJson(Map<String, dynamic> json) {
    return Penyewa(
      id: json['id'],
      nama: json['nama'],
      alamat: json['alamat'],
      nomorTelepon: json['nomorTelepon'],
      kendaraanId:
          json['kendaraanId'] as int?, // Pastikan untuk menangani parsing
    );
  }

  factory Penyewa.fromMap(Map<String, dynamic> map) {
    return Penyewa(
      id: map['id'],
      nama: map['nama'],
      alamat: map['alamat'],
      nomorTelepon: map['nomorTelepon'],
      kendaraanId:
          map['kendaraanId'] as int?, // Pastikan untuk menangani parsing
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'nomorTelepon': nomorTelepon,
      'kendaraanId': kendaraanId // Tambahkan ini
    };
  }
}
