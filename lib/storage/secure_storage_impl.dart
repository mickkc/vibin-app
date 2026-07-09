import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vibin_app/storage/secure_storage.dart';

/// Implementation of [SecureStorage] for all platforms but web, because web
/// required special logic for unsecure contexts (http://).
class SecureStorageImpl implements SecureStorage {

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);
}