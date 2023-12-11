import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteDb {
  static late Database _db;
  static String dataBase = "chatgpt.im.db";
  static int version = 1;

  static String message = 'message';
  static String chat = 'chat';

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // var batch = db.batch();
    // if (oldVersion < newVersion) {
    //   batch.execute('''
    //         CREATE TABLE IF NOT EXISTS book_read_cache(
    //           id INTEGER PRIMARY KEY AUTOINCREMENT,
    //           bid TEXT,
    //           cid TEXT,
    //           i INTEGER
    //         );
    //     ''');
    // }
    // await batch.commit();
  }

  Database? get db => _db;

  Future<void> delete() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dataBase);
    return await deleteDatabase(path);
  }

  Future<void> init() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, SqliteDb.dataBase);
    _db = await openDatabase(
      path,
      version: SqliteDb.version,
      onCreate: (Database db, int version) => _createTable(db),
      onUpgrade: (Database db, int oldVersion, int newVersion) =>
          _onUpgrade(db, oldVersion, newVersion),
    );
  }

  void _createTable(Database db) async{
    await db.execute(
        '''
            CREATE TABLE IF NOT EXISTS $chat(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              type TEXT,
              model TEXT,
              name TEXT,
              des TEXT,
              api_key TEXT,
              temperature TEXT,
              seed TEXT,
              max_token TEXT,
              n TEXT,
              size TEXT,
              create_time INTEGER,
              message_size TEXT
            );
            
        '''
    );
    await db.execute(
        '''
            CREATE TABLE IF NOT EXISTS $message(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              chat_id INTEGER,
              type TEXT,
              message TEXT,
              file TEXT,
              status TEXT,
              create_time INTEGER
            );
            
        '''
    );
    db.batch().commit();
  }
}
