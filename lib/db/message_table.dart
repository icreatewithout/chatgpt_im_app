
import 'package:chatgpt_im/db/sqlite.dart';
import 'package:sqflite/sqflite.dart';

import '../models/gpt/message.dart';

const columns = [
  'id',
  'chat_id',
  'type',
  'message',
  'status',
  'create_time'
];

class MessageProvider{

  final Database? db = SqliteDb().db;

  Future<List<Message>> findList() async {
    List<Map<String, dynamic>> maps = await db!.query(
      SqliteDb.chat,
      columns: columns,
      orderBy: 'create_time desc',
    );
    if (maps.isNotEmpty) {
      return maps.map((e) => Message.fromJson(e)).toList();
    }
    return [];
  }

  Future<Message?> insert(Message message) async {
    message.id = await db?.insert(SqliteDb.chat, message.toJson());
    return message;
  }

  Future<Message?> get(int id) async {
    List<Map<String, dynamic>> maps = await db!.query(
      SqliteDb.chat,
      columns: columns,
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
    return await db!.delete(SqliteDb.chat, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Message message) async {
    return await db!.update(SqliteDb.chat, message.toJson(),
        where: 'id = ?', whereArgs: [message.id]);
  }
}