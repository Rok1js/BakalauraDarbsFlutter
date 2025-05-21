import 'package:bakalauradarbsflutter/services/api_service.dart';
import 'package:bakalauradarbsflutter/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/home_page.dart';
import 'pages/category_page.dart';
import 'pages/post_detail_page.dart';
import 'models/post.dart';
import 'package:http/http.dart' as http;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await NotificationService.init();
  await Hive.initFlutter();
  await Hive.openBox('posts');

  // await Firebase.initializeApp();
  // await _initFCM();

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
        final uri = Uri.parse(settings.name ?? '');

        if (uri.path == '/') {
          return MaterialPageRoute(builder: (_) => const HomePage());
        }

        if (uri.pathSegments.length == 2 &&
            uri.pathSegments[0] == 'posts') {
          final category = uri.pathSegments[1];
          return MaterialPageRoute(
            builder: (_) => CategoryPage(category: category),
          );
        }

        if (uri.path == '/post' && settings.arguments is Post) {
          final post = settings.arguments as Post;
          return MaterialPageRoute(
            builder: (_) => PostDetailPage(post: post),
          );
        }

        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
      },
    );
  }
}

Future<void> _initFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission();
  print('Permission granted: ${settings.authorizationStatus}');

  final token = await messaging.getToken();
  print('FCM Token: $token');

  await http.post(
    Uri.parse('https://admin.gofinanceapp.lv/api/fcm-token'),
    body: {'token': token},
  );


  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('[FCM] Foreground: ${message.notification?.title}');

    final notification = message.notification;
    if (notification != null) {
      NotificationService.show(
        title: notification.title ?? 'No title',
        body: notification.body ?? 'No body',
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('[FCM] Opened from background: ${message.notification?.title}');
  });

  RemoteMessage? initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    print('[FCM] Launched from terminated: ${initialMessage.notification?.title}');
  }
}