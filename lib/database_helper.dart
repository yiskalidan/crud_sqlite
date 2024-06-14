import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'model/kendaraan.dart';
import 'model/penyewa.dart';
import 'model/transaksi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rental.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path,
        version: 1, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
CREATE TABLE kendaraan (
  id $idType,
  nama $textType,
  jenis $textType,
  tahun $integerType
)
''');

    await db.execute('''
CREATE TABLE penyewa (
  id $idType,
  nama $textType,
  alamat $textType,
  nomorTelepon $textType,  
  kendaraan_id $integerType,
  FOREIGN KEY (kendaraan_id) REFERENCES kendaraan (id)
)
''');

    // Tambahkan tabel transaksi
    await db.execute('''
CREATE TABLE transaksi (
  id $idType,
  tanggal $textType,
  jumlah $realType,
  keterangan $textType
)
''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Tambahkan tabel transaksi jika belum ada
      await db.execute('''
CREATE TABLE IF NOT EXISTS transaksi (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tanggal TEXT NOT NULL,
  jumlah REAL NOT NULL,
  keterangan TEXT NOT NULL
)
''');
    }
  }

// Menambahkan transaksi
  Future<int> insertTransaksi(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('transaksi', row);
  }

// Mengambil semua transaksi
  Future<List<Transaksi>> getAllTransaksi() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('transaksi');
    return List.generate(maps.length, (i) {
      return Transaksi.fromMap(maps[i]);
    });
  }

// Memperbarui transaksi
  Future<int> updateTransaksi(Transaksi transaksi) async {
    final db = await instance.database;
    return await db.update(
      'transaksi',
      transaksi.toMap(),
      where: 'id = ?',
      whereArgs: [transaksi.id],
    );
  }

// Menghapus transaksi
  Future<int> deleteTransaksi(int id) async {
    final db = await instance.database;
    return await db.delete(
      'transaksi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Kendaraan>> getKendaraan() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('kendaraan');

    return List<Kendaraan>.from(maps.map((map) => Kendaraan.fromMap(map)));
  }

  Future<Kendaraan?> getKendaraanById(int id) async {
    final db = await database;
    final maps = await db.query(
      'kendaraan',
      columns: [
        'id',
        'nama',
        'jenis',
        'tahun'
      ], // Sesuaikan kolom yang diperlukan
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Kendaraan.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> insertKendaraan(Map<String, dynamic> row) async {
    final db = await instance.database;
    return db.insert('kendaraan', row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateKendaraan(Map<String, dynamic> row) async {
    final db = await instance.database;
    return db.update('kendaraan', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deleteKendaraan(int id) async {
    final db = await instance.database;
    return db.delete('kendaraan', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Penyewa>> getPenyewa() async {
    var db = await database;
    List<Map<String, dynamic>> maps = await db.query('penyewa');
    return List.generate(maps.length, (i) {
      return Penyewa.fromMap(maps[i]);
    });
  }

  Future<Penyewa?> getPenyewaByKendaraanId(int kendaraanId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db
        .query('penyewa', where: 'kendaraan_id = ?', whereArgs: [kendaraanId]);

    if (results.isNotEmpty) {
      return Penyewa.fromJson(results.first);
    }
    return null;
  }

  Future<int> insertPenyewa(Map<String, dynamic> row) async {
    final db = await instance.database;
    return db.insert('penyewa', row);
  }

  Future<int> updatePenyewa(Map<String, dynamic> row) async {
    final db = await instance.database;
    return db.update('penyewa', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deletePenyewa(int id) async {
    final db = await instance.database;
    return db.delete('penyewa', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
