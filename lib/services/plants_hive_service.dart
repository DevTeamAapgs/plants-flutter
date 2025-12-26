import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:arumbu/constants/hive_boxes.dart';
import 'package:arumbu/constants/urls.dart';
import 'package:arumbu/model/sync_plants_response.dart';
import 'package:path_provider/path_provider.dart';

class PlantsHiveService {
  PlantsHiveService._();

  static const String _syncKey = 'plants_sync_payload';

  static Box<Data> get _box => Hive.box<Data>(HiveBoxes.syncPlants);

  static Data? get cachedData => _box.get(_syncKey);

  static List<Changes> get cachedPlants =>
      (cachedData?.changes ?? const <Changes>[])
          .where((change) => change.isDeleted != true)
          .toList();

  static Future<Data?> syncFromServer(BuildContext context) async {
    final response = await SyncPlantsResponse.getSyncPlants(context);
    final latest = response.data;
    if (latest == null) {
      return null;
    }

    await _cacheImagesForChanges(latest.changes ?? const <Changes>[]);

    final Map<String, Changes> merged = <String, Changes>{};
    for (final change in cachedData?.changes ?? const <Changes>[]) {
      final id = change.sId;
      if (id == null) continue;
      if (change.isDeleted == true) {
        merged.remove(id);
      } else {
        merged[id] = change;
      }
    }

    for (final change in latest.changes ?? const <Changes>[]) {
      final id = change.sId;
      if (id == null) continue;
      if (change.isDeleted == true) {
        merged.remove(id);
      } else {
        final existing = merged[id];
        if ((change.cachedImages == null || change.cachedImages!.isEmpty) &&
            existing?.cachedImages?.isNotEmpty == true) {
          change.cachedImages = List<String>.from(existing!.cachedImages!);
        }
        if ((change.images == null || change.images!.isEmpty) &&
            existing?.images?.isNotEmpty == true) {
          change.images = List<String>.from(existing!.images!);
        }
        merged[id] = change;
      }
    }

    final mergedList = merged.values.toList()
      ..sort(
        (a, b) => (a.botanicalName ?? '').toLowerCase().compareTo(
          (b.botanicalName ?? '').toLowerCase(),
        ),
      );

    final mergedData = Data(
      cursor: latest.cursor ?? cachedData?.cursor,
      changes: mergedList,
    );

    await _box.put(_syncKey, mergedData);
    return mergedData;
  }

  static Changes? getPlantById(String id) {
    for (final change in cachedData?.changes ?? const <Changes>[]) {
      if (change.isDeleted == true) {
        continue;
      }
      if (change.sId == id) return change;
    }
    return null;
  }

  static Future<void> _cacheImagesForChanges(List<Changes> changes) async {
    if (changes.isEmpty) return;
    final Directory baseDir = await _resolveImagesDirectory();
    final client = http.Client();

    try {
      for (final change in changes) {
        final cachedPaths = <String>[];
        final images = change.images ?? const <String>[];
        for (final imagePath in images) {
          final cached = await _cacheSingleImage(imagePath, baseDir, client);
          if (cached != null) {
            cachedPaths.add(cached);
          }
        }
        change.cachedImages = cachedPaths;
      }
    } finally {
      client.close();
    }
  }

  static Future<String?> _cacheSingleImage(
    String relativePath,
    Directory baseDir,
    http.Client client,
  ) async {
    if (relativePath.isEmpty) return null;

    final sanitized = _sanitizeRelativePath(relativePath);
    final extension = _fileExtension(sanitized);
    final encodedName = base64Url.encode(utf8.encode(sanitized));
    final fileName = extension != null ? '$encodedName$extension' : encodedName;
    final file = File('${baseDir.path}/$fileName');

    if (await file.exists()) {
      return 'file://${file.path}';
    }

    try {
      final uri = Uri.parse('${URLs.imageUrl}$relativePath');
      final resp = await client.get(uri);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        await file.writeAsBytes(resp.bodyBytes, flush: true);
        return 'file://${file.path}';
      }
      if (kDebugMode) {
        debugPrint(
          'Failed to cache image $relativePath: HTTP ${resp.statusCode}',
        );
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Image cache error for $relativePath: $error');
        debugPrint(stackTrace.toString());
      }
    }
    return null;
  }

  static String _sanitizeRelativePath(String path) {
    final withoutQuery = path.split('?').first;
    return withoutQuery.startsWith('/')
        ? withoutQuery.substring(1)
        : withoutQuery;
  }

  static String? _fileExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) {
      return null;
    }
    return path.substring(dotIndex);
  }

  static Future<Directory> _resolveImagesDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/plant_images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }
}
