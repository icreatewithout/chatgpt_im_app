import 'package:chatgpt_im/db/sqlite.dart';
import 'package:sqflite/sqflite.dart';

import '../models/gpt/message.dart';

const columns = [
  'id',
  'chat_id',
  'type',
  'message',
  'file',
  'status',
  'create_time'
];

class MessageProvider {
  final Database? db = SqliteDb().db;

  Future<List<Message>> findPage(int chatId, int offset, int limit) async {
    List<Map<String, dynamic>> maps = await db!.query(
      SqliteDb.message,
      columns: columns,
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'create_time desc',
      limit: limit * offset - 1,
      offset: (offset - 1) * limit,
    );
    if (maps.isNotEmpty) {
      return maps.map((e) => Message.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<Message>> findList() async {
    List<Map<String, dynamic>> maps = await db!.query(
      SqliteDb.message,
      columns: columns,
      orderBy: 'create_time desc',
    );
    if (maps.isNotEmpty) {
      return maps.map((e) => Message.fromJson(e)).toList();
    }
    return [];
  }

  Future<Message?> insert(Message message) async {
    message.id = await db?.insert(SqliteDb.message, message.toJson());
    return message;
  }

  Future<Message?> get(int id) async {
    List<Map<String, dynamic>> maps = await db!.query(
      SqliteDb.message,
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
    return await db!.delete(SqliteDb.message, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Message message) async {
    return await db!.update(SqliteDb.message, message.toJson(),
        where: 'id = ?', whereArgs: [message.id]);
  }
}
