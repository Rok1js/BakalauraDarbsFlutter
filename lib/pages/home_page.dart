import 'dart:async';
import 'package:bakalauradarbsflutter/background_sync_manager.dart';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/post_item.dart';
import '../widgets/navigation_drawer.dart' as custom;

// A list of category slugs to preload (adjust as needed)
const List<String> categoriesNames = [
  'world',
  'local',
  'business',
  'technology',
  'sports',
  'entertainment',
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<Post> posts = [];
  bool isLoading = true;

  final BackgroundSyncManager syncManager = BackgroundSyncManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initial load for all posts
    _fetchPosts();

    // Preload each category's posts into cache
    for (final category in categoriesNames) {
      ApiService.fetchCategoryPosts(category);
    }

    // Start periodic/background sync for posts
    syncManager.start();
  }

  Future<void> _fetchPosts() async {
    try {
      final data = await ApiService.fetchPosts();
      if (mounted) {
        setState(() {
          posts = data;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching posts: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // When app resumes from background, re-fetch posts
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchPosts();
    }
  }

  @override
  void dispose() {
    syncManager.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Navigation function for the drawer
  void _handleNavigate(String url) {
    if (url.isEmpty) {
      // Navigate to home by clearing navigation stack
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else {
      Navigator.pushNamed(context, '/$url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: custom.NavigationDrawer(onNavigate: _handleNavigate),
      appBar: AppBar(
        title: const Text('Ziņotājs'),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
          ? const Center(child: Text('No posts found'))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostItem(post: posts[index]);
          },
        ),
      ),
    );
  }
}
