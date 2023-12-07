import 'package:chatgpt_im/db/sqlite.dart';
import 'package:sqflite/sqflite.dart';

import '../models/message.dart';



class MessageProvider {
  final Database? db = SqliteDb().db;

  Future<List<Message>> findList() async {
    List<Map<String,dynamic>> maps = await db!.query(
      SqliteDb.messageSetting,
      columns: [
        'id',
        'type',
        'name',
        'des',
        'model',
        'api_key',
        'temperature',
        'seed',
        'max_token',
        'n',
        'size',
        'create_time',
        'message_size'
      ],
      orderBy: 'create_time desc',
    );
    if (maps.isNotEmpty) {
      return maps.map((e) => Message.fromJson(e)).toList();
    }
    return [];
  }

  Future<Message?> insert(Message message) async {
    message.id = await db?.insert(SqliteDb.messageSetting, message.toJson());
    return message;
  }

  Future<Message?> get(int id) async {
    List<Map<String,dynamic>> maps = await db!.query(
      SqliteDb.messageSetting,
      columns: [
        'id',
        'type',
        'name',
        'des',
        'model',
        'api_key',
        'temperature',
        'seed',
        'max_token',
        'n',
        'size',
        'create_time',
        'message_size'
      ],
      where: 'id = ?',
      whereArgs: [id],
      orderBy: 'id desc',
    );
    if (maps.isNotEmpty) {
      return Message.fromJson(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await db!
        .delete(SqliteDb.messageSetting, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Message message) async {
    return await db!.update(SqliteDb.messageSetting, message.toJson(),
        where: 'id = ?', whereArgs: [message.id]);
  }

  Future close() async => db!.close();
}
