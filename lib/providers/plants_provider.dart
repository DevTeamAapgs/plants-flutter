import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:arumbu/constants/urls.dart';
import 'package:arumbu/model/plants_list_response.dart';
import 'package:arumbu/services/plants_hive_service.dart';
import '../network/api_base_helper.dart';
import '../network/request_type.dart';

class PlantsProvider with ChangeNotifier {
  PlantsListResponse? _plantsListPageResponse;

  PlantsListResponse? get plantsListPageResponse => _plantsListPageResponse;

  final List<Plant?> _listofitems = [];
  bool isLoadingMore = false;
  bool hasMore = true;

  int _currentPage = 0;
  bool _isOfflinePrimed = false;

  List<Plant?> get listofitems => _listofitems;

  void resetProvider() {
    _listofitems.clear();
    _plantsListPageResponse = null;
    _currentPage = 0;
    hasMore = true;
    _isOfflinePrimed = false;
  }

  Future<void> loadFromCache() async {
    final cachedChanges = PlantsHiveService.cachedPlants;
    if (cachedChanges.isEmpty) {
      return;
    }
    _listofitems
      ..clear()
      ..addAll(cachedChanges.map((change) => Plant.fromSyncChange(change)));
    _isOfflinePrimed = true;
    notifyListeners();
  }

  Future<bool> performOfflineSync(BuildContext ctx) async {
    try {
      final data = await PlantsHiveService.syncFromServer(ctx);
      if (data != null && (_isOfflinePrimed || _listofitems.isEmpty)) {
        await loadFromCache();
      }
      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Sync plants failed: $error');
      }
      return false;
    }
  }

  Future<PlantsListResponse?> getPlantsList(
    BuildContext ctx, {
    dynamic body,
    bool isLoadMore = false,
  }) async {
    body ??= {};
    if (!hasMore) {
      return _plantsListPageResponse;
    }
    final nextPage = _currentPage + 1;
    body["page"] = nextPage;

    if (kDebugMode) {
      print(body.toString());
    }
    if (isLoadMore) {
      isLoadingMore = true;
      notifyListeners();
    }
    try {
      final ApiBaseHelper helper = ApiBaseHelper(ctx);
      final responseData = await helper.callAPI(
        URLs.getPlantsList,
        RequestType.GET,
        body: body,
      );

      if (responseData != null) {
        final PlantsListResponse response = PlantsListResponse.fromJson(
          responseData,
        );
        _plantsListPageResponse ??= response;

        if (nextPage == 1) {
          _listofitems.clear();
          _isOfflinePrimed = false;
        }

        final int before = _listofitems.length;
        final newItems = response.data?.plant ?? const <Plant>[];
        listofitems.addAll(newItems);

        final int after = _listofitems.length;
        hasMore = !(after == before && nextPage != 1);
        _currentPage = nextPage;

        if (nextPage == 1) {
          unawaited(
            PlantsHiveService.syncFromServer(ctx).catchError((error) {
              if (kDebugMode) {
                debugPrint('Background sync failed: $error');
              }
            }),
          );
        }
      }
    } on Exception catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Plants list fetch failed: $error');
        debugPrint(stackTrace.toString());
      }
      if (!isLoadMore) {
        // Offline fallback: load cached plants and apply client-side filtering
        await loadFromCache();

        final String query =
            (body['searchString'] as String?)?.trim().toLowerCase() ?? '';
        if (query.isNotEmpty) {
          _listofitems.retainWhere((plant) {
            final p = plant;
            if (p == null) return false;
            bool match(String? s) => (s ?? '').toLowerCase().contains(query);
            final langMatch = (p.languages ?? const []).any(
              (l) => match(l.name) || match(l.text) || match(l.description),
            );
            return match(p.botanicalName) ||
                match(p.familyName) ||
                match(p.habitName) ||
                match(p.speciesType) ||
                langMatch;
          });
        }
      }
      // Disable pagination when offline/error
      hasMore = false;
    } finally {
      if (isLoadMore) {
        isLoadingMore = false;
      }
      notifyListeners();
    }

    return _plantsListPageResponse;
  }
}
