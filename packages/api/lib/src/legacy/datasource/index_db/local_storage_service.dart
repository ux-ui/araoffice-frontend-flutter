import 'dart:async';

import 'package:idb_sqflite/idb_sqflite.dart';

import '../../domain/entities/entity.dart';

class LocalStorageService {
  static const String _dbName = 'local_project_db';
  static const int _dbVersion = 1;
  late Database _db;

  Future<void> open() async {
    var idbFactory = idbFactoryWeb;
    _db = await idbFactory.open(_dbName, version: _dbVersion,
        onUpgradeNeeded: (VersionChangeEvent event) {
      Database db = event.database;

      if (!db.objectStoreNames.contains('projects')) {
        db.createObjectStore('projects');
      }
      if (!db.objectStoreNames.contains('folders')) {
        db.createObjectStore('folders');
      }
      if (!db.objectStoreNames.contains('files')) {
        db.createObjectStore('files');
      }
    });
  }

  Future<void> saveProject(Map<String, dynamic> project) async {
    var txn = _db.transaction('projects', 'readwrite');
    var store = txn.objectStore('projects');
    await store.put(project, project['id']);
    await txn.completed;
  }

  Future<Map<String, dynamic>?> getProject(int id) async {
    var txn = _db.transaction('projects', 'readonly');
    var store = txn.objectStore('projects');
    return await store.getObject(id) as Map<String, dynamic>?;
  }

  Future<List<Map<String, dynamic>>> getAllProjects() async {
    var txn = _db.transaction('projects', 'readonly');
    var store = txn.objectStore('projects');
    List<Map<String, dynamic>> projects = [];
    await for (var cursor in store.openCursor()) {
      projects.add(cursor.value as Map<String, dynamic>);
      cursor.next();
    }
    return projects;
  }

  Future<void> deleteProject(int id) async {
    var txn = _db.transaction('projects', 'readwrite');
    var store = txn.objectStore('projects');
    await store.delete(id);
    await txn.completed;
  }

  Future<void> saveFolder(Map<String, dynamic> folder) async {
    var txn = _db.transaction('folders', 'readwrite');
    var store = txn.objectStore('folders');
    await store.put(folder, folder['id']);
    await txn.completed;
  }

  Future<Map<String, dynamic>?> getFolder(int id) async {
    var txn = _db.transaction('folders', 'readonly');
    var store = txn.objectStore('folders');
    return await store.getObject(id) as Map<String, dynamic>?;
  }

  Future<List<Map<String, dynamic>>> getAllFolders() async {
    var txn = _db.transaction('folders', 'readonly');
    var store = txn.objectStore('folders');
    List<Map<String, dynamic>> folders = [];
    await for (var cursor in store.openCursor()) {
      folders.add(cursor.value as Map<String, dynamic>);
      cursor.next();
    }
    return folders;
  }

  Future<void> deleteFolder(int id) async {
    var txn = _db.transaction('folders', 'readwrite');
    var store = txn.objectStore('folders');
    await store.delete(id);
    await txn.completed;
  }

  Future<void> saveFile(int projectId, Map<String, dynamic> file) async {
    var txn = _db.transaction('files', 'readwrite');
    var store = txn.objectStore('files');

    // Remove the 'path' from the file data before saving
    file.remove('path');

    await store.put(file, '${projectId}_${file['id']}');
    await txn.completed;
  }

  Future<Map<String, dynamic>?> getFile(String projectId, int fileId) async {
    var txn = _db.transaction('files', 'readonly');
    var store = txn.objectStore('files');
    var file =
        await store.getObject('${projectId}_$fileId') as Map<String, dynamic>?;

    if (file != null && file['base64Data'] != null) {
      final typeValue = file['fileType'];
      final type = typeValue is int
          ? _getMimeTypeFromStorageFileType(StorageFileType.values[typeValue])
          : 'application/octet-stream';
      file['path'] = _createBlobUrl(file['base64Data'], type: type);
    }

    return file;
  }

  Future<List<Map<String, dynamic>>> getFilesForProject(int projectId) async {
    var txn = _db.transaction('files', 'readonly');
    var store = txn.objectStore('files');
    List<Map<String, dynamic>> files = [];
    await for (var cursor in store.openCursor()) {
      if (cursor.key.toString().startsWith('${projectId}_')) {
        var file = cursor.value as Map<String, dynamic>;
        if (file['base64Data'] != null) {
          final typeValue = file['fileType'];
          final type = typeValue is int
              ? _getMimeTypeFromStorageFileType(
                  StorageFileType.values[typeValue])
              : 'application/octet-stream';
          file['path'] = _createBlobUrl(file['base64Data'], type: type);
        }
        files.add(file);
      }
      cursor.next();
    }
    return files;
  }

  Future<void> deleteFile(int projectId, int fileId) async {
    var txn = _db.transaction('files', 'readwrite');
    var store = txn.objectStore('files');
    await store.delete('${projectId}_$fileId');
    await txn.completed;
  }

  String _createBlobUrl(String base64Data,
      {String type = 'application/octet-stream'}) {
    // 데이터 URL 방식으로 사용
    return 'data:$type;base64,$base64Data';
  }

  Future<void> clearAllData() async {
    var txn = _db.transaction(['projects', 'folders', 'files'], 'readwrite');
    await txn.objectStore('projects').clear();
    await txn.objectStore('folders').clear();
    await txn.objectStore('files').clear();
    await txn.completed;
  }

  Future<void> close() async {
    _db.close();
  }

  String _getMimeTypeFromStorageFileType(StorageFileType fileType) {
    switch (fileType) {
      case StorageFileType.navigation:
      case StorageFileType.content:
        return 'application/xhtml+xml';
      case StorageFileType.style:
        return 'text/css';
      case StorageFileType.image:
        return 'image/png';
      case StorageFileType.font:
        return 'application/font-sfnt'; // 기본값
      case StorageFileType.audio:
        return 'audio/mpeg';
      case StorageFileType.video:
        return 'video/mp4';
      case StorageFileType.metadata:
        return 'application/oebps-package+xml';
      case StorageFileType.other:
        return 'application/octet-stream';
    }
  }
}
