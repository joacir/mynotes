// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:mynotes/extensions/list/filter.dart';
// import 'package:mynotes/services/crud/crud_exceptions.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' show join;

// const dbName = 'notes.db';
// const userTable = 'user';
// const noteTable = 'note';
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const textColumn = 'text';
// const isSyncedWithCloudColumn = 'is_synced_with_cloud';
// const createUserTable = '''
//   CREATE TABLE IF NOT EXISTS "user" (
//     "id"	INTEGER NOT NULL,
//     "email"	TEXT NOT NULL,
//     PRIMARY KEY("id" AUTOINCREMENT)
//   );
// ''';
// const createNoteTable = '''
//   CREATE TABLE IF NOT EXISTS "note" (
//     "id"	INTEGER NOT NULL,
//     "user_id"	INTEGER NOT NULL,
//     "text"	TEXT,
//     "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
//     FOREIGN KEY("user_id") REFERENCES "user"("id"),
//     PRIMARY KEY("id" AUTOINCREMENT)
//   );
// ''';

// class NotesService {

//   Database? _db;

//   DatabaseUser? _user;

//   List<DatabaseNote> _notes = [];

//   static final NotesService _shared = NotesService._sharedInstance();
//   NotesService._sharedInstance() {
//     _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: () {
//         _notesStreamController.sink.add(_notes);
//       }
//     );
//   }
//   factory NotesService() => _shared;

//   late final StreamController<List<DatabaseNote>> _notesStreamController;

//   Stream<List<DatabaseNote>> get allNotes =>
//     _notesStreamController.stream.filter((note) {
//       final currentUser = _user;
//       if (currentUser != null) {
//         return currentUser.id == note.userId;
//       } else {
//         throw UserMustBeSetBeforeGetAllNotesException();
//       }
//     });

//   Future<DatabaseUser> getOrCreateUser({required String email, bool setAsCurrentUser = true}) async {
//     try {
//       _ensureDbIsOpen();
//       final user = await getUser(email: email);
//       if (setAsCurrentUser) {
//         _user = user;
//       }

//       return user;
//     } on UserNotFoundException {
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser) {
//         _user = createdUser;
//       }

//       return createdUser;
//     } catch (_) {
//       rethrow;
//     }
//   }

//   Future<void> _cacheNotes() async {
//       _ensureDbIsOpen();
//     final notes = await getAllNotes();
//     _notes = notes.toList();
//     _notesStreamController.add(_notes);
//   }

//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {
//       //empty
//     }
//   }

//   Future<void> open() async {
//     if (_db != null) throw DatabaseAlreadyOpenException();
//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;
//       await db.execute(createUserTable);
//       await db.execute(createNoteTable);
//       _cacheNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentsDirectoryException();
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) throw DatabaseIsNotOpenException();
//     await db.close();
//     _db = null;
//   }

//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//       _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final user = await getUser(email: owner.email);
//     if (user != owner) throw UserNotFoundException();
//     const text = '';
//     final id = await db.insert(
//       noteTable,
//       {
//         textColumn: text,
//         userIdColumn: owner.id,
//         isSyncedWithCloudColumn: 1,
//       },
//     );

//     final note =  DatabaseNote(
//       id: id,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: true,
//     );
//     _notes.add(note);
//     _notesStreamController.add(_notes);

//     return note;
//   }

//   Future<void> deleteNote({required int id}) async {
//       _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       noteTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (deletedCount != 1) throw CouldNotDeleteNoteException();
//     _notes.removeWhere((note) => note.id == id);
//     _notesStreamController.add(_notes);
//   }

//   Future<int> deleteAllNotes() async {
//       _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deleteCount = await db.delete(noteTable);
//     _notes = [];
//     _notesStreamController.add(_notes);

//     return deleteCount;
//   }

//   Future<DatabaseNote> updateNote({
//     required DatabaseNote note,
//     required String text,
//   }) async {
//       _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     await getNote(id: note.id);
//     final updateCount = await db.update(
//       noteTable, {
//         textColumn: text,
//         isSyncedWithCloudColumn: 0,
//       },
//       where: 'id = ?',
//       whereArgs: [note.id]
//     );
//     if (updateCount == 0) throw CouldNotUpdateNoteException();

//     return await getNote(id: note.id);
//   }

//   Future<DatabaseNote> getNote({required int id}) async {
//       _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(
//       noteTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (notes.isEmpty) throw NoteNotFoundException();
//     final note = DatabaseNote.fromRow(notes.first);
//     _notes.removeWhere((note) => note.id == id);
//     _notes.add(note);
//     _notesStreamController.add(_notes);

//     return note;
//   }

//   Future<Iterable<DatabaseNote>> getAllNotes() async {
//       _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(noteTable);

//     return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//       _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final users = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (users.isNotEmpty) throw UserAlreadyExistsException();
//     final id = await db.insert(
//       userTable,
//       {emailColumn: email.toLowerCase()},
//     );

//     return DatabaseUser(
//       id: id,
//       email: email,
//     );
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//       _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final users = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (users.isEmpty) throw UserNotFoundException();

//     return DatabaseUser.fromRow(users.first);
//   }

//   Future<void> deleteUser({required String email}) async {
//       _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       userTable,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (deletedCount != 1) throw CouldNotDeleteUserException();
//   }

//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) throw DatabaseIsNotOpenException();

//     return db;
//   }
// }

// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;

//   const DatabaseUser({required this.id, required this.email});

//   DatabaseUser.fromRow(Map<String, Object?> map) :
//     id = map[idColumn] as int,
//     email = map[emailColumn] as String;

//   @override
//   String toString() => 'Person id: $id, e-mail: $email';

//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// @immutable
// class DatabaseNote {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;

//   const DatabaseNote({
//     required this.id,
//     required this.userId,
//     required this.text,
//     required this.isSyncedWithCloud,
//   });

//   DatabaseNote.fromRow(Map<String, Object?> map) :
//     id = map[idColumn] as int,
//     userId = map[userIdColumn] as int,
//     text = map[textColumn] as String,
//     isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

//   @override
//   String toString() => 'Note id: $id, userId: $userId, isSyncedWithCloud: $isSyncedWithCloud';

//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }