import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  static final DatabaseProvider instance = DatabaseProvider._init();
  static Database? _database;

  DatabaseProvider._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('corridas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    print("Abrindo banco de dados: $path");
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS corridas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT NOT NULL,
        descricao TEXT NOT NULL,
        data TEXT NOT NULL,
        hora TEXT NOT NULL,
        tempo INTEGER NOT NULL,
        distancia REAL NOT NULL
      )
    ''');
    print("Tabela 'corridas' criada!");
  }

  Future close() async {
    final db = await instance.database;
    db.close();
    print("Banco de dados fechado.");
  }
}
