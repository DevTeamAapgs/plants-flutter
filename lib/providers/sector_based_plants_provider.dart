import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:arumbu/model/plants_list_response.dart';
import '../constants/urls.dart';
import '../network/api_base_helper.dart';
import '../network/request_type.dart';

class SectorBasedPlantsProvider with ChangeNotifier {
  PlantsListResponse? _plantResponse;

  PlantsListResponse? get plantResponse => _plantResponse;

  final List<Plant?> _listofitems = [];
  bool isLoadingMore = false;
  bool hasMore = true;

  int _currentPage = 0;

  List<Plant?> get listofitems => _listofitems;

  void resetProvider() {
    _listofitems.clear();
    _plantResponse = null;
    _currentPage = 0;
    hasMore = true;
  }

  Future<PlantsListResponse?> getSectorBasedPlantList(
    BuildContext ctx, {
    dynamic body,
    bool isLoadMore = false,
  }) async {
    body ??= {};
    if (!hasMore) {
      return _plantResponse;
    }
    _currentPage += 1;
    body["page"] = _currentPage;

    if (kDebugMode) {
      print(body.toString());
    }
    if (isLoadMore) {
      isLoadingMore = true;
      notifyListeners();
    }
    // try {
    ApiBaseHelper helper = ApiBaseHelper(ctx);
    final responseData = await helper.callAPI(
      URLs.getPlantsList,
      RequestType.GET,
      body: body,
    );

    print("responseData : $responseData");

    if (_plantResponse != null) listofitems.remove(null);

    if (responseData != null) {
      log("respose received");
      try {
        PlantsListResponse response = PlantsListResponse.fromJson(responseData);

        _plantResponse ??= response;
        final int before = _listofitems.length;

        if (_currentPage == 1) {
          _listofitems.clear();
        }

        listofitems.addAll(response.data?.plant ?? []);
        final int after = _listofitems.length;

        if (after == before && _currentPage != 1) {
          hasMore = false;
        } else {
          hasMore = true;
        }
      } on Exception catch (e, s) {
        // TODO
        log("panjayathu $e - $s");
      }
    }
    if (isLoadMore) {
      isLoadingMore = false;
    }
    notifyListeners();

    return _plantResponse;
  }
}
