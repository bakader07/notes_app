import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class UnableToGetDocumentDirectoryException implements Exception {}

class DatabaseAlreadyOpenException implements Exception {}

class DatabaseIsNotOpenException implements Exception {}

// Users Exceptions
class CouldNotFindUserException implements Exception {}

class UserAlreadyExistsException implements Exception {}

class CouldNotCreateUserException implements Exception {}

class CouldNotDeleteUserException implements Exception {}

// Notes Exceptions
class CouldNotFindNoteException implements Exception {}

class CouldNotCreateNoteException implements Exception {}

class CouldNotDeleteNoteException implements Exception {}

class CouldNotUpdateNoteException implements Exception {}

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

  Future<DatabaseUser> createUser({required String email}) async {
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

  Future<void> deleteUser({required String email}) async {
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

    return DatabaseNote(
      id: createdNoteId,
      userId: owner.id,
      text: text,
      isSycedWithCloud: true,
    );
  }

  Future<DatabaseNote> getNote({required int id}) async {
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
      return DatabaseNote.fromRow(results.first);
    }
  }

  Future<List<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(notesTable);

    final notes = results.map((n) => DatabaseNote.fromRow(n));
    return notes.toList();
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      notesTable,
      where: '$idColumn = ?',
      whereArgs: [id],
    );
    if (deleteCount != 1) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(notesTable);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
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
      return await getNote(id: note.id);
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
