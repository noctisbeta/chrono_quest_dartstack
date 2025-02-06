import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:chrono_quest/dio_wrapper/dio_wrapper.dart';
import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class EncryptionRepository {
  EncryptionRepository({
    required FlutterSecureStorage storage,
    required DioWrapper authorizedDio,
  })  : _storage = storage,
        _authorizedDio = authorizedDio;

  final FlutterSecureStorage _storage;
  final DioWrapper _authorizedDio;

  late final String _masterKey;
  late final String _salt;
  late final String _dataEncryptionKey;

  Future<String> encrypt(String plaintext) async {
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(base64.decode(_dataEncryptionKey));
    final List<int> nonce = algorithm.newNonce();

    final SecretBox secretBox = await algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
    );

    final String encryptedData = base64.encode(secretBox.concatenation());
    return encryptedData;
  }

  Future<void> confirmPassphrase(String passphrase) async {
    _masterKey = await _generateMasterKey(passphrase);

    await _storage.write(key: 'masterKey', value: _masterKey);

    _salt = _generateSalt();

    _dataEncryptionKey = await _generateDataEncryptionKey(passphrase, _salt);

    final String encryptedSalt = await encrypt(_salt);

    try {
      await _authorizedDio.post(
        '/auth/encryption',
        data: {'encrypted_salt': encryptedSalt},
      );
    } on DioException catch (e) {
      throw Exception('Failed to save salt $e');
    }
  }

  Future<String> _generateMasterKey(String passphrase) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 1000,
      bits: 256,
    );

    final secretKey = SecretKey(utf8.encode(passphrase));
    final Uint8List nonce = Uint8List(0);

    final SecretKey newKey = await pbkdf2.deriveKey(
      secretKey: secretKey,
      nonce: nonce,
    );

    final List<int> newKeyBytes = await newKey.extractBytes();

    return base64.encode(newKeyBytes);
  }

  String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  Future<String> _generateDataEncryptionKey(
    String passphrase,
    String salt,
  ) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 1000,
      bits: 256,
    );

    final secretKey = SecretKey(utf8.encode(passphrase));
    final Uint8List nonce = base64.decode(salt);

    final SecretKey newKey = await pbkdf2.deriveKey(
      secretKey: secretKey,
      nonce: nonce,
    );

    final List<int> newKeyBytes = await newKey.extractBytes();

    return base64.encode(newKeyBytes);
  }

  Future<String?> getEncryptedSalt() async {
    try {
      final Response response = await _authorizedDio.get('/auth/encryption');

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;

      final String encryptedSalt = data['encrypted_salt'] as String;

      return encryptedSalt;
    } on DioException catch (e) {
      if (e.response?.statusCode == HttpStatus.notFound) {
        // User hasn't set up encryption yet
        return null;
      }
      throw Exception('Failed to get encrypted salt: $e');
    }
  }
}
