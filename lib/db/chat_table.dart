import 'package:chatgpt_im/db/sqlite.dart';
import 'package:sqflite/sqflite.dart';

import '../models/gpt/chat.dart';

const columns = [
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
  'style',
  'speed',
  'voice',
  'response_format',
  'create_time',
  'message_size'
];

class ChatProvider {
  final Database? db = SqliteDb().db;

  Future<List<Chat>> findList() async {
    List<Map<String, dynamic>> maps = await db!.query(
      SqliteDb.chat,
      columns: columns,
      orderBy: 'create_time desc',
    );
    if (maps.isNotEmpty) {
      return maps.map((e) => Chat.fromJson(e)).toList();
    }
    return [];
  }

  Future<Chat?> insert(Chat chat) async {
    chat.id = await db?.insert(SqliteDb.chat, chat.toJson());
    return chat;
  }

  Future<Chat?> get(int id) async {
    List<Map<String, dynamic>> maps = await db!.query(
      SqliteDb.chat,
      columns: columns,
      where: 'id = ?',
      whereArgs: [id],
      orderBy: 'id desc',
    );
    if (maps.isNotEmpty) {
      return Chat.fromJson(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await db!.delete(SqliteDb.chat, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Chat chat) async {
    return await db!.update(SqliteDb.chat, chat.toJson(),
        where: 'id = ?', whereArgs: [chat.id]);
  }

  Future close() async => db!.close();
}
