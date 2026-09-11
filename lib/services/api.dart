import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/posts_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // biar apa? biar ngambil semua data artikel yang ada di database 
  static Future<List<PostModel>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'];
      return data.map((json) => PostModel.fromJson(json)).toList();
    }
    return [];
  }

  // fungsi manfaat? fungsinya buat menambah data baru, manfaatnya? buat di baca org  
  static Future<bool> createPost({
    required int categoryId,
    required String title,
    required String content,
    String? image,
    required String author,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'categoryId': categoryId,
        'title': title,
        'content': content,
        'image': image,
        'author': author,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201; // intinya buat munculin status code, trs jg ada 201 krn ya dia method posts utk ngirim data dan 201 itu kl berhasil yh
  }

  // UPDATE POST
  static Future<bool> updatePost({
    required int id,
    required int categoryId,
    required String title,
    required String content,
    String? image,
    required String author,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/posts/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'categoryId': categoryId,
        'title': title,
        'content': content,
        'image': image,
        'author': author,
      }),
    );

    return response.statusCode == 200;
  }

  // DELETE POST
  static Future<bool> deletePost(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/posts/$id'));
    return response.statusCode == 200;
  }

  // GET ALL CATEGORIES
  static Future<List<CategoryModel>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'];
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    }
    return [];
  }
}

// intinya file code ini buat main function' an buat rest api nye biar tinggal manggil fungsi doang dh nntinye