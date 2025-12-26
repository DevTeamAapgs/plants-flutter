// lib/networkshowToastMessage.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:arumbu/constants/urls.dart';
import 'package:arumbu/utility/snackbar.dart';

class NetworkToast {
  NetworkToast._();
  static final NetworkToast _instance = NetworkToast._();
  factory NetworkToast() => _instance;

  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool? _lastOnline;
  Timer? _debounce;

  /// Call once (e.g., from your root widget's initState)
  void start() {
    // If already started, skip
    if (_sub != null) return;

    // Push initial status immediately
    _checkAndToast();

    _sub = Connectivity().onConnectivityChanged.listen((_) {
      // Debounce rapid changes (wifi<->cell handoff)
      _debounce?.cancel();
      _debounce = Timer(
        const Duration(milliseconds: 400),
        () => unawaited(_checkAndToast()),
      );
    });
  }

  void stop() {
    _debounce?.cancel();
    _sub?.cancel();
    _debounce = null;
    _sub = null;
    _lastOnline = null;
  }

  Future<void> _checkAndToast() async {
    final online = await _hasInternet();
    if (_lastOnline == null) {
      _lastOnline = online;
      return; // no toast on first run
    }

    // Show toast only on transitions
    if (_lastOnline == true && online == false) {
      showToastMessage('You’re offline');
    } else if (_lastOnline == false && online == true) {
      showToastMessage('Back online');
    }
    _lastOnline = online;
  }

  Future<bool> _hasInternet([
    Duration timeout = const Duration(seconds: 3),
  ]) async {
    try {
      final res = await http.head(Uri.parse(URLs.apiHealth)).timeout(timeout);
      return res.statusCode == 204 ||
          (res.statusCode >= 200 && res.statusCode < 400);
    } catch (_) {
      return false;
    }
  }
}
