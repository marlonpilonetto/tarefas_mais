import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'meu_banco.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tarefas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT,
            subtitulo TEXT,
            cor INTEGER,
            status TEXT,
            concluido INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE pessoas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT,
            token TEXT
          )
        ''');
      },
    );
  }

  static Future<void> inserirPessoa(String token) async {
    final db = await database;
    await db.insert('pessoas', {'token': token});
  }

  static Future<List<Map<String, dynamic>>> listarPessoas() async {
    final db = await database;
    return await db.query('pessoas');
  }

  static Future<void> inserirTarefa(Map<String, dynamic> tarefa) async {
    final db = await database;
    await db.insert('tarefas', {
      'titulo': tarefa['titulo'],
      'subtitulo': tarefa['subtitulo'],
      'cor': tarefa['cor'].value, // Salva como int
      'status': tarefa['status'],
      'concluido': tarefa['concluido'] ? 1 : 0,
    });
  }

  static Future<List<Map<String, dynamic>>> listarTarefas() async {
    final db = await database;
    final result = await db.query('tarefas');
    return result.map((t) => {
      ...t,
      'cor': Color(t['cor'] as int),
      'concluido': t['concluido'] == 1,
    }).toList();
  }

  static Future<void> atualizarTarefa(int id, Map<String, dynamic> tarefa) async {
    final db = await database;
    await db.update(
      'tarefas',
      {
        'titulo': tarefa['titulo'],
        'subtitulo': tarefa['subtitulo'],
        'cor': tarefa['cor'].value,
        'status': tarefa['status'],
        'concluido': tarefa['concluido'] ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> excluirTarefa(int id) async {
    final db = await database;
    await db.delete('tarefas', where: 'id = ?', whereArgs: [id]);
  }
}

