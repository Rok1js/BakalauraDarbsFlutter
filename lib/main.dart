import 'package:bakalauradarbsflutter/services/api_service.dart';
import 'package:bakalauradarbsflutter/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/home_page.dart';
import 'pages/category_page.dart';
import 'pages/post_detail_page.dart';
import 'models/post.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().initNotification();
  await Hive.initFlutter();
  await Hive.openBox('posts');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ziņotājs',
      theme: ThemeData.dark(),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Extract route + arguments
        final uri = Uri.parse(settings.name ?? '');

        if (uri.path == '/') {
          return MaterialPageRoute(builder: (_) => const HomePage());
        }

        // Handle category route like /posts/world
        if (uri.pathSegments.length == 2 &&
            uri.pathSegments[0] == 'posts') {
          final category = uri.pathSegments[1];
          return MaterialPageRoute(
            builder: (_) => CategoryPage(category: category),
          );
        }

        // Handle post detail via arguments
        if (uri.path == '/post' && settings.arguments is Post) {
          final post = settings.arguments as Post;
          return MaterialPageRoute(
            builder: (_) => PostDetailPage(post: post),
          );
        }

        // Unknown route fallback
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
      },
    );
  }
}