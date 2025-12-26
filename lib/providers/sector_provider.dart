import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:arumbu/model/sector_response.dart';
import '../constants/urls.dart';
import '../network/api_base_helper.dart';
import '../network/request_type.dart';

class SectorProvider with ChangeNotifier {
  SectorPageResponse? _sectorResponse;

  SectorPageResponse? get sectorResponse => _sectorResponse;

  final List<Items?> _listofitems = [];
  bool isLoadingMore = false;
  bool hasMore = true;

  int _currentPage = 0;

  List<Items?> get listofitems => _listofitems;

  void resetProvider() {
    _listofitems.clear();
    _sectorResponse = null;
    _currentPage = 0;
    hasMore = true;
  }

  Future<SectorPageResponse?> getSectorList(
    BuildContext ctx, {
    dynamic body,
    bool isLoadMore = false,
  }) async {
    body ??= {};
    if (!hasMore) {
      return _sectorResponse;
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
      URLs.getSectorList,
      RequestType.GET,
      body: body,
    );

    print("responseData : $responseData");

    if (_sectorResponse != null) listofitems.remove(null);

    if (responseData != null) {
      log("respose received");
      try {
        SectorPageResponse response = SectorPageResponse.fromJson(responseData);

        _sectorResponse ??= response;
        final int before = _listofitems.length;

        if (_currentPage == 1) {
          _listofitems.clear();
        }

        listofitems.addAll(response.sector?.items ?? []);
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

    return _sectorResponse;
  }
}
