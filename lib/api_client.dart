import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

const _baseUrl = 'http://mobcrud.atwebpages.com/api';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> saveToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await prefs.remove('auth_token');
    } else {
      await prefs.setString('auth_token', token);
    }
  }

  Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<User> login(String email, String password) async {
    final res = await _client.post(
      Uri.parse('$_baseUrl/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    _throwOnError(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = data['token'] as String?;
    if (token != null) await saveToken(token);
    return User.fromJson(data['user'] as Map<String, dynamic>, token: token);
  }

  Future<User> register({
    required String email,
    required String password,
    String first = '',
    String last = '',
  }) async {
    final res = await _client.post(
      Uri.parse('$_baseUrl/register.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'first_name': first,
        'last_name': last,
      }),
    );
    _throwOnError(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = data['token'] as String?;
    if (token != null) await saveToken(token);
    return User.fromJson(data['user'] as Map<String, dynamic>, token: token);
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

  Future<List<Country>> fetchFavorites() async {
    final token = await loadToken();
    final res = await _client.get(
      Uri.parse('$_baseUrl/favorites.php'),
      headers: _authHeaders(token),
    );
    _throwOnError(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final favorites = data['favorites'] as List<dynamic>;
    return favorites
        .map((e) => Country.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFavorite(int countryId) async {
    final token = await loadToken();
    final res = await _client.post(
      Uri.parse('$_baseUrl/favorites.php'),
      headers: _authHeaders(token),
      body: jsonEncode({'country_id': countryId}),
    );
    _throwOnError(res);
  }

  Future<void> removeFavorite(int countryId) async {
    final token = await loadToken();
    final request = http.Request(
      'DELETE',
      Uri.parse('$_baseUrl/favorites.php'),
    )
      ..headers.addAll(_authHeaders(token))
      ..body = jsonEncode({'country_id': countryId});
    final streamed = await _client.send(request);
    final res = await http.Response.fromStream(streamed);
    _throwOnError(res);
  }

  Future<void> updateProfilePicUrl(String url) async {
    final token = await loadToken();
    final res = await _client.post(
      Uri.parse('$_baseUrl/profile_picture.php'),
      headers: _authHeaders(token),
      body: jsonEncode({'profile_pic_url': url}),
    );
    _throwOnError(res);
  }

  Map<String, String> _authHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void _throwOnError(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }
}
