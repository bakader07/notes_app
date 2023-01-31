import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import './crud_exceptions.dart';

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes = [];

  // Turning the class constructor into a singleton instance
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory NotesService() => _shared;

  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  Future<void> _cachedNotes() async {
    _notes = await getAllNotes();
    _notesStreamController.add(_notes);
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // Create users table
      await db.execute(createUsersTable);
      // Create notes table
      await db.execute(createNotesTable);
      // Cache available notes
      await _cachedNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectoryException();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    }
    await db.close();
    _db = null;
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> _ensureDatabaseIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // Carry on
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    // Checking if user already exists
    final results = await db.query(
      usersTable,
      limit: 1,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }
    // Creating user
    final createdUserId = await db.insert(
      usersTable,
      {emailColumn: email.toLowerCase()},
    );
    if (createdUserId == 0) {
      throw CouldNotCreateUserException();
    }

    return DatabaseUser(id: createdUserId, email: email);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    // Checking if user already exists
    final results = await db.query(
      usersTable,
      limit: 1,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUserException {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      usersTable,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deleteCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    // Make sure owner exists in the database with the same id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }

    const text = '';
    // Create note
    final createdNoteId = await db.insert(notesTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSycedWithCloudColumn: 1,
    });
    if (createdNoteId == 0) {
      throw CouldNotCreateNoteException();
    }

    final createdNote = DatabaseNote(
      id: createdNoteId,
      userId: owner.id,
      text: text,
      isSycedWithCloud: true,
    );

    _notes.add(createdNote);
    _notesStreamController.add(_notes);

    return createdNote;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    // Checking if note exists
    final results = await db.query(
      notesTable,
      limit: 1,
      where: '$idColumn = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      final note = DatabaseNote.fromRow(results.first);
      _notes.removeWhere((n) => n.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<List<DatabaseNote>> getAllNotes() async {
    await _ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(notesTable);

    final notes = results.map((n) => DatabaseNote.fromRow(n));
    return notes.toList();
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      notesTable,
      where: '$idColumn = ?',
      whereArgs: [id],
    );
    if (deleteCount != 1) {
      throw CouldNotDeleteNoteException();
    } else {
      // Remove note from cache
      final notesCount = _notes.length;
      _notes.removeWhere((note) => note.id == id);
      if (_notes.length < notesCount) {
        _notesStreamController.add(_notes);
      }
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(notesTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return deleteCount;
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDatabaseIsOpen();
    final db = _getDatabaseOrThrow();

    //verifying that the note exists
    await getNote(id: note.id);

    final updatedNotesCount = await db.update(
      notesTable,
      {
        textColumn: text,
        isSycedWithCloudColumn: 0,
      },
      where: '$idColumn = ?',
      whereArgs: [note.id],
    );

    if (updatedNotesCount == 0) {
      throw CouldNotUpdateNoteException();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((n) => n.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'User, ID: $id, Email: $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSycedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSycedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSycedWithCloud =
            (map[isSycedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() => 'Note, ID: $id, User ID: $userId, Text: $text'
      ', IsSycedWithCloud: $isSycedWithCloud';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const usersTable = 'users';
const notesTable = 'notes';

const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSycedWithCloudColumn = 'is_syced_with_cloud';

const createUsersTable = '''CREATE TABLE IF NOT EXISTS "$usersTable" (
  "$idColumn" INTEGER NOT NULL,
  "$emailColumn" TEXT NOT NULL UNIQUE,
  PRIMARY KEY ("$idColumn" AUTOINCREMENT)
);''';

const createNotesTable = '''CREATE TABLE IF NOT EXISTS "$notesTable" (
  "$idColumn" INTEGER NOT NULL,
  "$userIdColumn" INTEGER NOT NULL,
  "$textColumn" TEXT,
  "$isSycedWithCloudColumn" INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY ("$userIdColumn") REFERENCES "$usersTable"("$idColumn"),
  PRIMARY KEY ("$idColumn" AUTOINCREMENT)
);''';
