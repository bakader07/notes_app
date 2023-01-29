import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;

class UnableToGetDocumentDirectoryException implements Exception {}

class DatabaseAlreadyOpenException implements Exception {}

class DatabaseIsNotOpenException implements Exception {}

class NotesService {
  Database? _db;

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
  PRIMARY KEY ("$idColumn", AUTOINCREMENT)
);''';

const createNotesTable = '''CREATE TABLE IF NOT EXISTS "$notesTable" (
  "$idColumn" INTEGER NOT NULL,
  "$userIdColumn" INTEGER NOT NULL UNIQUE,
  "$textColumn" TEXT,
  "$isSycedWithCloudColumn" INTEGER NOT NULL UNIQUE DEFAULT 0,
  FOREIGN KEY ("$userIdColumn") REFRENCES "$usersTable"("$idColumn"),
  PRIMARY KEY ("$idColumn", AUTOINCREMENT)
);''';
