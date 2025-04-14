import 'package:bakalauradarbsflutter/services/api_service.dart';
import 'package:bakalauradarbsflutter/services/notification_service.dart';
import 'package:flutter/material.dart';
import '../constants/categories.dart';

class NavigationDrawer extends StatelessWidget {
  final void Function(String url) onNavigate;

  const NavigationDrawer({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              title: Text(
                'Kategorijas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return ListTile(
                    title: Text(
                      cat['name']!,
                      style: const TextStyle(color: Colors.white),
                    ),
                      onTap: () {
                        Navigator.pop(context); // close drawer

                        final isHome = cat['url']!.isEmpty;

                        if (isHome) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                                (route) => false, // remove everything else
                          );
                        } else {
                          final slug = cat['url']!.split('/').last;
                          Navigator.pushNamed(context, '/posts/$slug');
                        }
                      }
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
