import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/post.dart';

class ApiService {
  static const String baseUrl = 'https://admin.gofinanceapp.lv/api';

  static Future<List<Post>> fetchPosts() async {
    final box = Hive.box('posts');

    try {
      final response = await http.get(Uri.parse('$baseUrl/posts'));

      if (response.statusCode == 200) {
        List jsonList = jsonDecode(response.body);
        await box.put('allPosts', response.body);
        return jsonList.map((e) => Post.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      final cached = box.get('allPosts');
      if (cached != null) {
        List jsonList = jsonDecode(cached);
        return jsonList.map((e) => Post.fromJson(e)).toList();
      } else {
        throw Exception('Offline and no cached posts');
      }
    }
  }

  static Future<Post> fetchPostById(int id) async {
    final box = Hive.box('posts');
    final key = 'post_$id';

    try {
      final response = await http.get(Uri.parse('$baseUrl/posts/$id'));

      if (response.statusCode == 200) {
        await box.put(key, response.body);
        return Post.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load post');
      }
    } catch (e) {
      final cached = box.get(key);
      if (cached != null) {
        return Post.fromJson(jsonDecode(cached));
      } else {
        throw Exception('Offline and no cached post');
      }
    }
  }

  static Future<List<Post>> fetchCategoryPosts(String category) async {
    final box = Hive.box('posts');
    final key = 'category_$category';

    try {
      final response = await http.get(Uri.parse('$baseUrl/posts/$category'));

      if (response.statusCode == 200) {
        await box.put(key, response.body);
        List jsonList = jsonDecode(response.body);
        return jsonList.map((e) => Post.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load category posts');
      }
    } catch (e) {
      final cached = box.get(key);
      if (cached != null) {
        List jsonList = jsonDecode(cached);
        return jsonList.map((e) => Post.fromJson(e)).toList();
      } else {
        throw Exception('Offline and no cached category posts');
      }
    }
  }
}
