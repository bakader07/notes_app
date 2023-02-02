class CloudStorageException implements Exception {
  const CloudStorageException();
}

//* Notes CRUD Exceptions

class CouldNotCreateNoteException extends CloudStorageException {}

class CouldNotFindNoteException extends CloudStorageException {}

class CouldNotGetAllNotesException extends CloudStorageException {}

class CouldNotDeleteNoteException extends CloudStorageException {}

class CouldNotUpdateNoteException extends CloudStorageException {}
