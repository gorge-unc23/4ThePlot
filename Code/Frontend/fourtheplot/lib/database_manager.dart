import 'dart:convert';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fourtheplot/models/registration.dart';
import 'package:fourtheplot/pages/main_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fourtheplot/models/comment.dart';
import 'package:fourtheplot/models/event.dart';
import 'package:fourtheplot/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class ApiResult {
  final bool success;
  final int status;
  final String message;
  final dynamic data;
  final String? token;
  final String? expiresAt;

  ApiResult({
    required this.success,
    required this.status,
    required this.message,
    this.data,
    this.token,
    this.expiresAt,
  });

  @override
  String toString() =>
      'ApiResult(success: $success, status: $status, message: $message, data: $data)';

  ApiResult copyWith({
    bool? success,
    int? status,
    String? message,
    dynamic data,
    String? token,
    String? expiresAt,
  }) {
    return ApiResult(
      success: success ?? this.success,
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class ApiToken {
  final String accessToken;
  final String tokenType;

  const ApiToken({required this.accessToken, required this.tokenType});

  factory ApiToken.fromJson(Map<String, dynamic> json) {
    return ApiToken(
      accessToken: (json['access_token'] as String?) ?? '',
      tokenType: (json['token_type'] as String?) ?? 'bearer',
    );
  }
}

class DatabaseHelper {
  static const _accessTokenKey = 'auth.accessToken';
  static const _tokenTypeKey = 'auth.tokenType';
  static const _userKey = 'auth.user';
  static const _serverIpKey = 'server.ip';
  static const _requestTimeout = Duration(seconds: 20);
  static const _defaultServerIp = String.fromEnvironment(
    'SERVER_IP',
    defaultValue: '192.168.100.8:8000',
  );

  String serverIp = _defaultServerIp;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  String? _accessToken;
  String? _tokenType;
  bool _loadedStoredToken = false;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Map<String, _CacheEntry> _cache = {};

  Uri _apiUri(String path, [Map<String, dynamic>? query]) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final queryParameters = <String, String>{};
    if (query != null) {
      for (final entry in query.entries) {
        final value = entry.value;
        if (value == null) continue;
        final stringValue = value.toString();
        if (stringValue.isEmpty) continue;
        queryParameters[entry.key] = stringValue;
      }
    }

    return Uri.parse(
      'http://$serverIp/$normalizedPath',
    ).replace(queryParameters: queryParameters.isEmpty ? null : queryParameters);
  }

  Future<void> _loadStoredToken() async {
    if (_loadedStoredToken) {
      return;
    }

    _accessToken = await _secureStorage.read(key: _accessTokenKey);
    _tokenType = await _secureStorage.read(key: _tokenTypeKey);
    _loadedStoredToken = true;
  }

  Future<void> loadServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    final savedServerIp = prefs.getString(_serverIpKey)?.trim();
    if (savedServerIp != null && savedServerIp.isNotEmpty) {
      serverIp = _normalizeServerIp(savedServerIp);
    }
  }

  Future<void> saveServerIp(String value) async {
    final normalizedServerIp = _normalizeServerIp(value);
    serverIp = normalizedServerIp;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverIpKey, normalizedServerIp);
  }

  String _normalizeServerIp(String value) {
    var normalized = value.trim();
    normalized = normalized.replaceFirst(RegExp(r'^https?://'), '');
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  Future<void> setAuthToken(String token, {String tokenType = 'bearer'}) async {
    _accessToken = token;
    _tokenType = tokenType.isEmpty ? 'bearer' : tokenType;
    _loadedStoredToken = true;

    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: token),
      _secureStorage.write(key: _tokenTypeKey, value: _tokenType),
    ]);
  }

  Future<void> clearAuthToken() async {
    _accessToken = null;
    _tokenType = null;
    _loadedStoredToken = true;

    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _tokenTypeKey),
    ]);
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return User.fromJson(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> clearStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<void> clearSession() async {
    await Future.wait([clearAuthToken(), clearStoredUser()]);
  }

  Map<String, String> _headers({bool json = true, bool authenticated = true}) {
    final headers = <String, String>{};
    if (json) {
      headers['Content-Type'] = 'application/json';
    }
    headers['Accept'] = 'application/json';

    if (authenticated && _accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = '${_authScheme(_tokenType)} $_accessToken';
    }
    return headers;
  }

  String _authScheme(String? tokenType) {
    final normalized = tokenType?.trim();
    if (normalized == null || normalized.isEmpty) {
      return 'Bearer';
    }
    return normalized.toLowerCase() == 'bearer' ? 'Bearer' : normalized;
  }

  Future<ApiResult> _request(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    bool isForm = false,
    bool authenticated = true,
  }) async {
    final uri = _apiUri(path, query);
    try {
      if (authenticated) {
        await _loadStoredToken();
      }

      http.Response response;
      if (method == 'GET') {
        response = await http
            .get(uri, headers: _headers(authenticated: authenticated))
            .timeout(_requestTimeout);
      } else if (method == 'POST') {
        response = await http
            .post(
              uri,
              headers: _headers(json: !isForm, authenticated: authenticated),
              body: isForm ? _formBody(body) : jsonEncode(body ?? {}),
            )
            .timeout(_requestTimeout);
      } else if (method == 'PUT') {
        response = await http
            .put(
              uri,
              headers: _headers(authenticated: authenticated),
              body: jsonEncode(body ?? {}),
            )
            .timeout(_requestTimeout);
      } else if (method == 'DELETE') {
        response = await http
            .delete(uri, headers: _headers(authenticated: authenticated))
            .timeout(_requestTimeout);
      } else {
        return ApiResult(success: false, status: -1, message: 'Unsupported method');
      }

      final decoded = _decodeJson(response.body);
      final message = _extractMessage(decoded, response.statusCode);
      final success = response.statusCode >= 200 && response.statusCode < 300;

      if (response.statusCode == 401 && authenticated) {
        await clearAuthToken();
      }

      return ApiResult(
        success: success,
        status: response.statusCode,
        message: message,
        data: decoded,
      );
    } catch (error, stackTrace) {
      log('API request failed', error: error, stackTrace: stackTrace);
      return ApiResult(success: false, status: -1, message: 'network-error');
    }
  }

  Future<ApiResult> _multipartRequest(
    String method,
    String path, {
    required List<http.MultipartFile> files,
    Map<String, String>? fields,
    bool authenticated = true,
  }) async {
    final uri = _apiUri(path);
    try {
      if (authenticated) {
        await _loadStoredToken();
      }

      final request = http.MultipartRequest(method, uri);
      request.headers.addAll(_headers(json: false, authenticated: authenticated));
      request.fields.addAll(fields ?? const {});
      request.files.addAll(files);

      final streamedResponse = await request.send().timeout(_requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      final decoded = _decodeJson(response.body);
      final message = _extractMessage(decoded, response.statusCode);
      final success = response.statusCode >= 200 && response.statusCode < 300;

      if (response.statusCode == 401 && authenticated) {
        await clearAuthToken();
      }

      return ApiResult(
        success: success,
        status: response.statusCode,
        message: message,
        data: decoded,
      );
    } catch (error, stackTrace) {
      log('Multipart API request failed', error: error, stackTrace: stackTrace);
      return ApiResult(success: false, status: -1, message: 'network-error');
    }
  }

  dynamic _decodeJson(String body) {
    if (body.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  Map<String, String> _formBody(Map<String, dynamic>? body) {
    final formBody = <String, String>{};
    if (body == null) {
      return formBody;
    }

    for (final entry in body.entries) {
      final value = entry.value;
      if (value == null) continue;
      formBody[entry.key] = value.toString();
    }
    return formBody;
  }

  String _extractMessage(dynamic decoded, int statusCode) {
    if (decoded is Map<String, dynamic>) {
      final detail = decoded['detail'] ?? decoded['message'];
      if (detail != null) {
        return detail.toString();
      }
    }
    return statusCode >= 200 && statusCode < 300 ? 'ok' : 'error';
  }

  Future<ApiResult> login(String email, String password) async {
    final result = await _request(
      'POST',
      'login/',
      body: {'username': email, 'password': password},
      isForm: true,
      authenticated: false,
    );

    if (!result.success || result.data is! Map<String, dynamic>) {
      return result;
    }

    final payload = result.data as Map<String, dynamic>;
    final token = ApiToken.fromJson(payload);
    if (token.accessToken.isNotEmpty) {
      await setAuthToken(token.accessToken, tokenType: token.tokenType);
    }

    final user = _extractUserFromLogin(payload);
    if (user != null) {
      await saveUser(user);
      MainWrapper.loggedInUser = user;
    }

    return result.copyWith(data: user ?? token, token: token.accessToken);
  }

  User? _extractUserFromLogin(Map<String, dynamic> payload) {
    Map<String, dynamic>? userJson;

    final nestedUser = payload['user'];
    if (nestedUser is Map<String, dynamic>) {
      userJson = nestedUser;
    } else if (payload.containsKey('displayName') && payload.containsKey('email')) {
      userJson = payload;
    }

    if (userJson == null) {
      return null;
    }

    try {
      return User.fromJson(userJson);
    } catch (_) {
      return null;
    }
  }

  Future<ApiResult> getUser(int userId) async {
    final result = await _request('GET', 'user/$userId');
    if (!result.success || result.data is! Map<String, dynamic>) {
      return result;
    }
    return result.copyWith(data: User.fromJson(result.data as Map<String, dynamic>));
  }

  Future<ApiResult> createUser(Map<String, dynamic> payload) async {
    return _request('POST', 'user/', body: payload);
  }

  Future<ApiResult> updateUser(int userId, Map<String, dynamic> payload) async {
    return _request('PUT', 'user/$userId', body: payload);
  }

  Future<ApiResult> getNotTrustedUsers() async {
    final result = await _request('GET', 'user/not-trusted');
    if (!result.success) {
      return result;
    }

    final list = (result.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(User.fromJson)
        .toList();
    return result.copyWith(data: list);
  }

  Future<ApiResult> markUserAsTrusted(User user) async {
    final credibility = user.hostCredibility;
    return updateUser(user.id, {
      'host_credibility': {
        'rating': credibility?.rating,
        'review_count': credibility?.reviewCount,
        'trusted': true,
      },
    });
  }

  Future<ApiResult> deleteUser(int userId) async {
    return _request('DELETE', 'user/$userId');
  }

  Future<ApiResult> getAllEvents({bool useCache = true}) async {
    const cacheKey = 'events';
    final result = await _request('GET', 'events/');
    if (!result.success) {
      if (useCache && _cache.containsKey(cacheKey)) {
        return result.copyWith(
          success: true,
          status: 200,
          message: 'offline-cache',
          data: _cache[cacheKey]!.data,
        );
      }
      return result;
    }

    final list = (result.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Event.fromJson)
        .toList();
    _cache[cacheKey] = _CacheEntry(list);
    return result.copyWith(data: list);
  }

  Future<ApiResult> getTrendingEvents({bool useCache = true}) async {
    const cacheKey = 'events';
    final result = await _request('GET', 'events/trending/');
    if (!result.success) {
      if (useCache && _cache.containsKey(cacheKey)) {
        return result.copyWith(
          success: true,
          status: 200,
          message: 'offline-cache',
          data: _cache[cacheKey]!.data,
        );
      }
      return result;
    }

    final list = (result.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Event.fromJson)
        .toList();
    _cache[cacheKey] = _CacheEntry(list);
    return result.copyWith(data: list);
  }

  Future<ApiResult> getEvent(int eventId) async {
    final result = await _request('GET', 'events/$eventId');
    if (!result.success || result.data is! Map<String, dynamic>) {
      return result;
    }
    return result.copyWith(data: Event.fromJson(result.data as Map<String, dynamic>));
  }

  Future<ApiResult> createEvent(Map<String, dynamic> payload) async {
    return _request('POST', 'events/', body: payload);
  }

  Future<ApiResult> uploadCoverImage(XFile image) async {
    final bytes = await image.readAsBytes();
    final file = http.MultipartFile.fromBytes(
      'photo',
      bytes,
      filename: image.name,
      contentType: _imageContentType(image.name),
    );
    final result = await _multipartRequest('POST', 'events/photos', files: [file]);
    if (!result.success || result.data is! Map<String, dynamic>) {
      return result;
    }

    final payload = result.data as Map<String, dynamic>;
    final coverImageUrl = payload['coverImageUrl'] as String?;
    if (coverImageUrl == null || coverImageUrl.isEmpty) {
      return result.copyWith(success: false, message: 'missing-cover-image-url');
    }

    return result.copyWith(data: coverImageUrl);
  }

  MediaType _imageContentType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  Future<ApiResult> updateEvent(int eventId, Map<String, dynamic> payload) async {
    return _request('PUT', 'events/$eventId', body: payload);
  }

  Future<ApiResult> deleteEvent(int eventId) async {
    return _request('DELETE', 'events/$eventId');
  }

  Future<ApiResult> getNearbyEvents(double lat, double lng, {double radius = 10}) async {
    final result = await _request(
      'GET',
      'events/nearby/search',
      query: {'lat': lat, 'lng': lng, 'radius': radius},
    );
    if (!result.success) {
      return result;
    }
    final list = (result.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Event.fromJson)
        .toList();
    return result.copyWith(data: list);
  }

  Future<ApiResult> getSearchedEvents(String searchCriteria) async {
    final result = await _request('GET', 'events/search', query: {'q': searchCriteria});
    if (!result.success) {
      return result;
    }
    final list = (result.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Event.fromJson)
        .toList();
    return result.copyWith(data: list);
  }

  Future<ApiResult> getCityEvents(String city) async {
    final result = await _request('GET', 'events/city/$city');
    if (!result.success) {
      return result;
    }
    final list = (result.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Event.fromJson)
        .toList();
    return result.copyWith(data: list);
  }

  Future<ApiResult> getCityHostEvents(String city, int hostId) async {
    final result = await _request('GET', 'events/host/$hostId/city/$city');
    if (!result.success) {
      return result;
    }
    final list = (result.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Event.fromJson)
        .toList();
    return result.copyWith(data: list);
  }

  Future<ApiResult> getRegisteredEvents(int userId) async {
    final result = await _request('GET', 'events/registered/$userId');
    if (!result.success) {
      return result;
    }
    final list = (result.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Event.fromJson)
        .toList();
    return result.copyWith(data: list);
  }

  Future<ApiResult> getEventsByHostId(int hostId) async {
    final result = await _request('GET', 'events/host/$hostId');
    if (!result.success) {
      return result;
    }
    final list = (result.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Event.fromJson)
        .toList();
    return result.copyWith(data: list);
  }

  Future<ApiResult> getComment(int commentId) async {
    final result = await _request('GET', 'comments/$commentId');
    if (!result.success || result.data is! Map<String, dynamic>) {
      return result;
    }
    return result.copyWith(data: Comment.fromJson(result.data as Map<String, dynamic>));
  }

  Future<ApiResult> getCommentsByEvent(int eventId) async {
    final result = await _request('GET', 'comments/event/$eventId');
    if (!result.success) {
      return result;
    }
    final list =
        (result.data as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(Comment.fromJson)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result.copyWith(data: list);
  }

  Future<ApiResult> createComment(Map<String, dynamic> payload) async {
    return _request('POST', 'comments/', body: payload);
  }

  Future<ApiResult> deleteComment(int commentId) async {
    return _request('DELETE', 'comments/$commentId');
  }

  Future<ApiResult> createRegistration(Map<String, dynamic> payload) async {
    return _request('POST', 'registration/', body: payload);
  }

  Future<ApiResult> getRegistrationsByUser(int userId) async {
    final result = await _request('GET', 'registration/user/$userId');
    if (!result.success) {
      return result;
    }
    final list = (result.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    return result.copyWith(data: list);
  }

  Future<ApiResult> getRegistrationForUserEvent(int userId, int eventId) async {
    final result = await _request('GET', 'registration/user/$userId/event/$eventId');
    final registration = (result.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Registration.fromJson)
        .toList();

    if (registration.isNotEmpty) {
      return result.copyWith(data: registration[0]);
    }

    return result.copyWith(data: null);
  }

  Future<ApiResult> deleteRegistration(int registrationId) async {
    return _request('DELETE', 'registration/$registrationId');
  }
}

class _CacheEntry {
  final DateTime timestamp;
  final dynamic data;

  _CacheEntry(this.data) : timestamp = DateTime.now();
}
