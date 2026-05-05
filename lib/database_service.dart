import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'campus_vote.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Implementing your DB schema logic here
    await db.execute('''
      CREATE TABLE users (
        student_id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        has_voted INTEGER DEFAULT 0,
        voted_at DATETIME
      )
    ''');

    await db.execute('''
      CREATE TABLE positions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE candidates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        position_id INTEGER,
        vote_count INTEGER DEFAULT 0,
        FOREIGN KEY (position_id) REFERENCES positions(id)
      )
    ''');
  }
}

  
