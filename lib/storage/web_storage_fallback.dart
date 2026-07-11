import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vibin_app/storage/secure_storage.dart';
import 'package:vibin_app/storage/webstub/web_wrapper.dart';

/// Implementation of [SecureStorage] for web, that automatically uses localStorage
/// instead of secure storage in unsecure contexts (http://).
class WebStorageFallback implements SecureStorage {

  final FlutterSecureStorage _httpsStorage = const FlutterSecureStorage();

  @override
  Future<void> delete(String key) async {
    // On HTTP, secure storage is not supported, use local storage instead.
    if (getBrowserProtocol() == "http:") {
      return removeBrowserItem(key);
    }
    // On HTTPS, secure storage is supported.
    return _httpsStorage.delete(key: key);
  }

  @override
  Future<String?> read(String key) async {
    // On HTTP, secure storage is not supported, use local storage instead.
    if (getBrowserProtocol() == "http:") {
      return getBrowserItem(key);
    }
    // On HTTPS, secure storage is supported.
    return _httpsStorage.read(key: key);
  }

  @override
  Future<void> write(String key, String value) async {
    // On HTTP, secure storage is not supported, use local storage instead.
    if (getBrowserProtocol() == "http:") {
      return setBrowserItem(key, value);
    }
    // On HTTPS, secure storage is supported.
    return _httpsStorage.write(key: key, value: value);
  }
}