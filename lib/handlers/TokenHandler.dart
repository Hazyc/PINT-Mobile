import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class TokenHandler {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Guarda o token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  // Busca o token
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  // Apaga o token
  Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
  }
}