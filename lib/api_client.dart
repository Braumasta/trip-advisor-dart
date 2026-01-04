import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'models.dart';

const _baseUrl = 'http://mobcrud.atwebpages.com/api';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<User> login(String email, String password) async {
    final res = await _client.post(
      Uri.parse('$_baseUrl/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    _throwOnError(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<User> register({
    required String email,
    required String password,
    String first = '',
    String last = '',
    String dob = '',
  }) async {
    final res = await _client.post(
      Uri.parse('$_baseUrl/register.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'first_name': first,
        'last_name': last,
        if (dob.isNotEmpty) 'dob': dob,
      }),
    );
    _throwOnError(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<List<Country>> fetchCountries() async {
    final res = await _client.get(Uri.parse('$_baseUrl/countries.php'));
    _throwOnError(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final countries = data['countries'] as List<dynamic>;
    return countries
        .map((e) => Country.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Tip>> fetchTips(int countryId) async {
    final res = await _client.get(
      Uri.parse('$_baseUrl/tips.php?country_id=$countryId'),
    );
    _throwOnError(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final tips = data['tips'] as List<dynamic>;
    return tips.map((e) => Tip.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Country>> fetchFavorites(int userId) async {
    final res = await _client.get(
      Uri.parse('$_baseUrl/favorites.php?user_id=$userId'),
    );
    _throwOnError(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final favorites = data['favorites'] as List<dynamic>;
    return favorites
        .map((e) => Country.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFavorite({required int userId, required int countryId}) async {
    final res = await _client.post(
      Uri.parse('$_baseUrl/favorites.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'country_id': countryId}),
    );
    _throwOnError(res);
  }

  Future<void> removeFavorite({required int userId, required int countryId}) async {
    final request = http.Request(
      'DELETE',
      Uri.parse('$_baseUrl/favorites.php'),
    )
      ..headers.addAll({'Content-Type': 'application/json'})
      ..body = jsonEncode({'user_id': userId, 'country_id': countryId});
    final streamed = await _client.send(request);
    final res = await http.Response.fromStream(streamed);
    _throwOnError(res);
  }

  Future<User> updateProfile({
    required int userId,
    String? firstName,
    String? lastName,
    String? dob,
    String? profilePicUrl,
  }) async {
    final res = await _client.post(
      Uri.parse('$_baseUrl/update_profile.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (dob != null) 'dob': dob,
        if (profilePicUrl != null) 'profile_pic_url': profilePicUrl,
      }),
    );
    _throwOnError(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await _client.post(
      Uri.parse('$_baseUrl/change_password.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );
    _throwOnError(res);
  }

  Future<void> deleteAccount(int userId) async {
    final res = await _client.send(http.Request(
      'DELETE',
      Uri.parse('$_baseUrl/delete_account.php'),
    )
      ..headers.addAll({'Content-Type': 'application/json'})
      ..body = jsonEncode({'user_id': userId}));
    final full = await http.Response.fromStream(res);
    _throwOnError(full);
  }

  Future<void> addCountry({
    required int userId,
    required String name,
    required String description,
    required String flagAsset,
    required String accentHex,
    required List<String> etiquetteTips,
    required List<String> travelTips,
  }) async {
    final cleanedAccent = accentHex.replaceAll('#', '').toUpperCase();
    final res = await _client.post(
      Uri.parse('$_baseUrl/add_country.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'name': name,
        'description': description,
        'flag_asset': flagAsset,
        'accent_hex': cleanedAccent,
        'etiquette_tips': etiquetteTips,
        'travel_tips': travelTips,
      }),
    );
    _throwOnError(res);
    try {
      final body = jsonDecode(res.body);
      if (body is Map<String, dynamic>) {
        final ok = body['ok'] == true;
        if (!ok) {
          throw Exception(body['error'] ?? 'Failed to add country');
        }
        return;
      }
    } catch (_) {
      // fall through to generic error
    }
    throw Exception('Failed to add country: ${res.body}');
  }

  Future<void> deleteCountry({required int userId, required int countryId}) async {
    final res = await _client.send(http.Request(
      'DELETE',
      Uri.parse('$_baseUrl/delete_country.php'),
    )
      ..headers.addAll({'Content-Type': 'application/json'})
      ..body = jsonEncode({'user_id': userId, 'country_id': countryId}));
    final full = await http.Response.fromStream(res);
    _throwOnError(full);
  }

  Future<void> updateCountry({
    required int userId,
    required int countryId,
    String? name,
    String? description,
    String? flagAsset,
    String? accentHex,
    List<String>? etiquetteTips,
    List<String>? travelTips,
  }) async {
    final cleanedAccent =
        accentHex != null ? accentHex.replaceAll('#', '').toUpperCase() : null;
    final res = await _client.post(
      Uri.parse('$_baseUrl/update_country.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'country_id': countryId,
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (flagAsset != null) 'flag_asset': flagAsset,
        if (cleanedAccent != null) 'accent_hex': cleanedAccent,
        if (etiquetteTips != null) 'etiquette_tips': etiquetteTips,
        if (travelTips != null) 'travel_tips': travelTips,
      }),
    );
    _throwOnError(res);
    try {
      final body = jsonDecode(res.body);
      if (body is Map<String, dynamic>) {
        final ok = body['ok'] == true;
        if (!ok) {
          throw Exception(body['error'] ?? 'Failed to update country');
        }
        return;
      }
    } catch (_) {
      // fall through
    }
    throw Exception('Failed to update country: ${res.body}');
  }

  Future<String> uploadImage({
    required String target, // 'flag' or 'pfp'
    required Uint8List bytes,
    required String filename,
  }) async {
    final uri = Uri.parse('$_baseUrl/upload_image.php');
    final request = http.MultipartRequest('POST', uri)
      ..fields['target'] = target
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    final streamed = await _client.send(request);
    final res = await http.Response.fromStream(streamed);
    _throwOnError(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final url = data['url'] as String?;
    if (url == null || url.isEmpty) throw Exception('upload failed');
    return url;
  }

  void _throwOnError(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }
}
