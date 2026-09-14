import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/posts_model.dart';
import '../models/comment_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiService {
  static const String _defaultBaseUrl = 'http://localhost:5000/api';
  static String _baseUrl = _defaultBaseUrl;
  static String? _token;

  static void setToken(String? token) {
    _token = token;
  }

  static String? get token => _token;

  static String get baseUrl => _baseUrl;

  static void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static void resetBaseUrl() {
    _baseUrl = _defaultBaseUrl;
  }

  static void setAndroidEmulatorUrl() {
    _baseUrl = 'http://10.0.2.2:5000/api';
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw ApiException('Respons JSON tidak valid');
      }
    }
    String message;
    try {
      final body = jsonDecode(response.body);
      message = body['message'] ?? 'Request gagal (${response.statusCode})';
    } catch (_) {
      message = 'Request gagal (${response.statusCode})';
    }
    throw ApiException(message, statusCode: response.statusCode);
  }

  // AUTH
  static Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    ).timeout(const Duration(seconds: 15));

    final body = _handleResponse(response);
    return body != null ? body['data'] as Map<String, dynamic>? : null;
  }

  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    ).timeout(const Duration(seconds: 15));

    final body = _handleResponse(response);
    if (body != null) {
      final data = body['data'];
      _token = data['token'];
      return data as Map<String, dynamic>?;
    }
    return null;
  }

  static void logout() {
    _token = null;
  }

  // POSTS
  static Future<List<PostModel>> getPosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts'),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));

    final body = _handleResponse(response);
    final List<dynamic> data = body['data'] ?? [];
    return data.map((json) => PostModel.fromJson(json)).toList();
  }

  static Future<PostModel?> getPostById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$id'),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));

    final body = _handleResponse(response);
    if (body == null) return null;
    return PostModel.fromJson(body['data']);
  }

  static Future<List<PostModel>> searchPosts(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/search?q=${Uri.encodeComponent(query)}'),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));

    final body = _handleResponse(response);
    final List<dynamic> data = body['data'] ?? [];
    return data.map((json) => PostModel.fromJson(json)).toList();
  }

  static Future<PostModel?> createPost({
    required int categoryId,
    required String title,
    required String content,
    String? imagePath,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/posts'));
    if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
    request.fields['categoryId'] = categoryId.toString();
    request.fields['title'] = title;
    request.fields['content'] = content;
    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('picture', imagePath));
    }

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);

    final body = _handleResponse(response);
    if (body == null) return null;
    return PostModel.fromJson(body['data']);
  }

  static Future<PostModel?> updatePost({
    required int id,
    required int categoryId,
    required String title,
    required String content,
    String? imagePath,
    String? existingPicture,
  }) async {
    var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/posts/$id'));
    if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
    request.fields['categoryId'] = categoryId.toString();
    request.fields['title'] = title;
    request.fields['content'] = content;
    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('picture', imagePath));
    } else if (existingPicture != null) {
      request.fields['picture'] = existingPicture;
    }

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);

    final body = _handleResponse(response);
    if (body == null) return null;
    return PostModel.fromJson(body['data']);
  }

  static Future<bool> deletePost(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$id'),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));

    _handleResponse(response);
    return true;
  }

  // CATEGORIES
  static Future<List<CategoryModel>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
    ).timeout(const Duration(seconds: 15));

    final body = _handleResponse(response);
    final List<dynamic> data = body['data'] ?? [];
    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }

  // COMMENTS
  static Future<List<CommentModel>> getComments(int postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId/comments'),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));

    final body = _handleResponse(response);
    final List<dynamic> data = body?['data'] ?? [];
    return data.map((json) => CommentModel.fromJson(json)).toList();
  }

  static Future<CommentModel?> addComment(int postId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/comments'),
      headers: _headers,
      body: jsonEncode({'content': content}),
    ).timeout(const Duration(seconds: 15));

    final body = _handleResponse(response);
    if (body == null) return null;
    return CommentModel.fromJson(body['data']);
  }

  static Future<bool> deleteComment(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/comments/$id'),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));

    _handleResponse(response);
    return true;
  }

  // LIKES
  static Future<Map<String, dynamic>?> toggleLike(int postId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/like'),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));

    final body = _handleResponse(response);
    if (body == null) return null;
    return {
      'liked': body['liked'],
      'likeCount': body['likeCount'],
    };
  }

  // SAVES
  static Future<bool> toggleSave(int postId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/save'),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));

    _handleResponse(response);
    return true;
  }

  static Future<List<PostModel>> getSavedPosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me/saved-posts'),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));

    final body = _handleResponse(response);
    final List<dynamic> data = body['data'] ?? [];
    return data.map((json) => PostModel.fromJson(json)).toList();
  }

  // USER
  static Future<Map<String, dynamic>?> getMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));

    final body = _handleResponse(response);
    return body != null ? body['data'] as Map<String, dynamic>? : null;
  }

  static Future<List<PostModel>> getUserPosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me/posts'),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));

    final body = _handleResponse(response);
    final List<dynamic> data = body['data'] ?? [];
    return data.map((json) => PostModel.fromJson(json)).toList();
  }
}


