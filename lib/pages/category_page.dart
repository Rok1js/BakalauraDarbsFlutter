import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/post_item.dart';
import '../widgets/navigation_drawer.dart';
import '../widgets/navigation_drawer.dart' as custom;

class CategoryPage extends StatefulWidget {
  final String category;

  const CategoryPage({super.key, required this.category});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<Post>> futurePosts;

  @override
  void initState() {
    super.initState();
    futurePosts = ApiService.fetchCategoryPosts(widget.category);
  }

  void _handleNavigate(String url) {
    Navigator.pushNamed(context, '/posts/$url');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: custom.NavigationDrawer(onNavigate: _handleNavigate),
      appBar: AppBar(
        title: Text(widget.category.toUpperCase()),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: FutureBuilder<List<Post>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading posts'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No posts found'));
          }

          final posts = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostItem(post: posts[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
