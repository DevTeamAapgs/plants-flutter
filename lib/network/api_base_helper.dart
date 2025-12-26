import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../network/app_exception.dart';
import '../network/request_type.dart';
import 'package:arumbu/providers/loading_provider.dart';

class ApiBaseHelper {
  final BuildContext ctx;
  ApiBaseHelper(this.ctx);

  /// Main API caller
  Future<dynamic> callAPI(
    String url,
    RequestType requestType, {
    Map<String, String>? headers,
    dynamic body,
    Duration timeout = const Duration(seconds: 25),
  }) async {
    // final loadingState = Provider.of<ApiLoadingState>(ctx, listen: false);

    // ---- Merge headers (caller wins) ----
    final mergedHeaders = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json', // harmless for GET
      'mobile': '1',
      ...?headers,
    };

    http.Response resp;

    // ---- Build final URI (GET uses body as query) ----
    final Uri uri = (requestType == RequestType.GET)
        ? _buildUri(url, (body is Map) ? Map<String, dynamic>.from(body) : null)
        : Uri.parse(url);

    // ---- Logging (compact + safe) ----
    _log('REQUEST  → $requestType $uri');
    _log('HEADERS  → ${_compactMap(mergedHeaders)}');
    if (requestType != RequestType.GET) {
      _log('BODY     → ${_safeJson(body)}');
    } else if (body != null && (body is Map) && body.isNotEmpty) {
      _log('QUERY    → ${_compactMap(body)}');
    }

    try {
      // loadingState.startLoading();

      switch (requestType) {
        case RequestType.GET:
          resp = await http.get(uri, headers: mergedHeaders).timeout(timeout);
          break;
        case RequestType.POST:
          resp = await http
              .post(uri, headers: mergedHeaders, body: json.encode(body ?? {}))
              .timeout(timeout);
          break;
        case RequestType.PUT:
          resp = await http
              .put(uri, headers: mergedHeaders, body: json.encode(body ?? {}))
              .timeout(timeout);
          break;
        case RequestType.DELETE:
          resp = await http
              .delete(
                uri,
                headers: mergedHeaders,
                body: json.encode(body ?? {}),
              )
              .timeout(timeout);
          break;
        case RequestType.PATCH:
          resp = await http
              .patch(uri, headers: mergedHeaders, body: json.encode(body ?? {}))
              .timeout(timeout);
          break;
      }

      _log('STATUS   ← ${resp.statusCode} (${resp.reasonPhrase ?? ''})');
      _log('CT       ← ${resp.headers['content-type'] ?? '(none)'}');

      return _handleResponse(resp, uri.toString());
    } on SocketException catch (e) {
      // Most common causes: wrong host (Android emulator needs 10.0.2.2), DNS, firewall, no internet.
      _err('SOCKET   ✖ ${e.message}');
      throw FetchDataException('No internet/host unreachable: ${e.message}');
    } on TimeoutException {
      _err('TIMEOUT  ✖ ${timeout.inSeconds}s at $uri');
      throw FetchDataException('Request timed out after ${timeout.inSeconds}s');
    } on HttpException catch (e) {
      _err('HTTP     ✖ $e');
      rethrow;
    } catch (e, st) {
      _err('UNKNOWN  ✖ $e');
      if (kDebugMode) _err(st.toString());
      throw FetchDataException('Unexpected error calling $uri: $e');
    } finally {
      // loadingState.stopLoading();
    }
  }

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------

  /// Build a URI and only add query if body is non-null & non-empty.
  Uri _buildUri(String url, Map<String, dynamic>? query) {
    final base = Uri.parse(url);
    if (query == null || query.isEmpty) return base;

    // Merge with existing query (preserve existing)
    final merged = <String, List<String>>{};
    base.queryParametersAll.forEach((k, v) => merged[k] = List.of(v));

    query.forEach((k, v) {
      if (v == null) return;
      if (v is Iterable) {
        final list = v
            .where((e) => e != null)
            .map((e) => e.toString())
            .toList();
        if (list.isNotEmpty) merged[k] = list;
      } else {
        merged[k] = [v.toString()];
      }
    });

    return base.replace(queryParameters: merged);
  }

  /// Unified response handler for http.Response
  dynamic _handleResponse(http.Response response, String url) {
    final status = response.statusCode;
    final ct = (response.headers['content-type'] ?? '').toLowerCase();
    final bodyStr = response.body;

    // 204 No Content (or empty body)
    if (status == 204 || bodyStr.isEmpty) {
      if (status >= 200 && status < 300) return null;
      throw _httpToException(status, 'No content', url);
    }

    // Success 2xx
    if (status >= 200 && status < 300) {
      if (ct.contains('application/json')) {
        final decoded = _tryDecodeJson(bodyStr);
        _logBodyPreview(decoded);
        return decoded;
      }
      // Non-JSON success (e.g., PDF, image, CSV, etc.)
      _log('BYTES    ← ${response.bodyBytes.length} bytes');
      return {
        'bytes': response.bodyBytes,
        'contentType': response.headers['content-type'],
        'statusCode': status,
        'url': url,
      };
    }

    // Error branch: try to extract server message if JSON
    String message = 'HTTP $status';
    if (ct.contains('application/json')) {
      final decoded = _tryDecodeJson(bodyStr);
      if (decoded is Map && decoded['message'] != null) {
        message = decoded['message'].toString();
      } else {
        message = decoded.toString();
      }
    } else {
      message = '${response.reasonPhrase ?? 'Error'}: $bodyStr';
    }

    _err('ERROR    ← $status | $message');
    throw _httpToException(status, message, url);
  }

  Exception _httpToException(int status, String message, String url) {
    switch (status) {
      case 400:
        return BadRequestException(message);
      case 401:
      case 403:
        return UnauthorisedException(message);
      case 404:
        return BadRequestException('Not found: $url');
      case 500:
        return FetchDataException('Server error (500): $message');
      default:
        return FetchDataException(
          'HTTP $status while calling $url: ${message.trim()}',
        );
    }
  }

  dynamic _tryDecodeJson(String body) {
    try {
      return json.decode(body);
    } catch (_) {
      // Fallback: return raw text if the server sent invalid/partial JSON.
      return body;
    }
  }

  // ---- Logging helpers ----
  void _log(String msg) => developer.log(msg, name: 'API');
  void _err(String msg) => developer.log(msg, name: 'API', level: 1000);

  String _compactMap(dynamic m) {
    if (m is Map) {
      final parts = <String>[];
      m.forEach((k, v) {
        if (v == null) return;
        final val = v.toString();
        parts.add(
          '$k=${val.length > 120 ? '${val.substring(0, 117)}...' : val}',
        );
      });
      return '{${parts.join(', ')}}';
    }
    return m?.toString() ?? '{}';
  }

  String _safeJson(dynamic data) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data ?? {});
    } catch (_) {
      return data?.toString() ?? '{}';
    }
  }

  void _logBodyPreview(dynamic decoded) {
    if (!kDebugMode) return;
    String preview;
    if (decoded is String) {
      preview = decoded;
    } else {
      preview = const JsonEncoder.withIndent('  ').convert(decoded);
    }
    if (preview.length > 800) preview = '${preview.substring(0, 800)}...';
    _log('BODY     ← $preview');
  }
}
