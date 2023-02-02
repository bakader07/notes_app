import 'package:cloud_firestore/cloud_firestore.dart';

import './cloud_storage_constants.dart';
import './cloud_storage_exceptions.dart';
import './cloud_note.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');
  // static instance
  static final _storage = FirebaseCloudStorage._instance();

  factory FirebaseCloudStorage() => _storage;

  // Constructor
  FirebaseCloudStorage._instance();

  Future<CloudNote> createNote({required String userId}) async {
    try {
      final document = await notes.add({
        userIdField: userId,
        textField: '',
      });
      final noteSnapshot = await document.get();
      return CloudNote(
        id: noteSnapshot.id,
        userId: userId,
        text: '',
      );
    } catch (_) {
      throw CouldNotCreateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String userId}) =>
      notes.snapshots().map(
            (event) => event.docs
                .map((doc) => CloudNote.fromSnapshot(doc))
                .where((note) => note.userId == userId),
          );

  Future<Iterable<CloudNote>> getNotes({required String userId}) async {
    try {
      final notesQuerySnapshot =
          await notes.where(userIdField, isEqualTo: userId).get();
      final results = notesQuerySnapshot.docs.map(
        (doc) => CloudNote.fromSnapshot(doc),
      );
      return results;
    } catch (_) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<void> updateNote({required String docId, required String text}) async {
    try {
      await notes.doc(docId).update({textField: text});
    } catch (_) {
      CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String docId}) async {
    try {
      await notes.doc(docId).delete();
    } catch (_) {
      CouldNotDeleteNoteException();
    }
  }
}
