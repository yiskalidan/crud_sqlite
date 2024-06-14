class Kendaraan {
  final int? id;
  final String nama;
  final String jenis;
  final int tahun;

  Kendaraan(
      {this.id, required this.nama, required this.jenis, required this.tahun});

  factory Kendaraan.fromMap(Map<String, dynamic> map) {
    return Kendaraan(
      id: map['id'],
      nama: map['nama'],
      jenis: map['jenis'],
      tahun: map['tahun'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'jenis': jenis,
      'tahun': tahun,
    };
  }
}
