// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class DB {
//   DB._();

//   static final DB instance = DB._();

//   static Database? _database;

//   get database async {
//     if (_database != null) return _database;

//     return await _initDatabase();
//   }

//   _initDatabase() async {
//     return await openDatabase(
//       join(await getDatabasesPath(), 'historico.db'),
//       version: 1,
//       onCreate: _onCreate,
//     );
//   }

//   _onCreate(db, versao) async {
//     await db.execute(_historico);
//   }

//   String get _historico => '''
//     CREATE TABLE historicoTable (
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       data TEXT,
//       caminhao TEXT,
//       posto TEXT,
//       odometro INT,
//       litros TEXT,
//       valor TEXT
//     );
//   ''';
// }
