
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_constants.dart';
import 'package:mynotes/services/cloud/cloud_exceptions.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';

class FirebaseCloudStorage {
  static final FirebaseCloudStorage _shared = FirebaseCloudStorage.sharedInstance();
  FirebaseCloudStorage.sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  final _notes = FirebaseFirestore.instance.collection('notes');

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
    _notes.snapshots().map(
      (event) => event.docs
      .map((doc) => CloudNote.fromSnapshot(doc))
      .where((note) => note.ownerUserId == ownerUserId)
    );

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await _notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    final fetchedNote = await document.get();

    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await _notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await _notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await _notes
        .where(
          ownerUserIdFieldName,
          isEqualTo: ownerUserId,
        )
        .get()
        .then(
          (value) => value.docs.map(
            (doc) => CloudNote.fromSnapshot(doc)
          ),
        );
    } catch (e) {
      throw CouldNotReadNoteException();
    }
  }
}