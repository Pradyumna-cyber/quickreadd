import 'package:flutter/material.dart';
import 'package:quickreadd/pages/terms.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'about.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<String> favoriteNews = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites(); // Load favorites on startup
  }

  // Function to load favorite articles from SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteNews = prefs.getStringList('favoriteNews') ?? [];
    });
  }

  // Function to toggle favorite status
  Future<void> _toggleFavorite(String article) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteNews.contains(article)) {
        favoriteNews.remove(article); // Remove if already in favorites
      } else {
        favoriteNews.add(article); // Add to favorites
      }
    });
    // Save the updated favorite articles list to SharedPreferences
    await prefs.setStringList('favoriteNews', favoriteNews);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background color
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        children: [
          // Settings Section Title
          const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 8),
            child: Text(
              "Account",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          // Profile
          _buildSettingsTile(
            context,
            icon: Icons.person_outline,
            title: 'Profile',
            onTap: () => print('Profile tapped'),
          ),

          // Notifications
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () => print('Notifications tapped'),
          ),

          const Divider(height: 30), // Divider for separation

          // Terms and Conditions
          _buildSettingsTile(
            context,
            icon: Icons.article_outlined,
            title: 'Terms and Conditions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermsAndConditionsPage()),
              );
            },
          ),


          // About
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: 'About',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>AboutPage()));
            },
          ),

          // Favourites - Show favorite news
          _buildSettingsTile(
            context,
            icon: Icons.favorite_border,
            title: 'Favourites',
            onTap: () {
              // Navigate to a new page showing the list of favorite articles
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteNewsPage(
                    favoriteNews: favoriteNews,
                    toggleFavorite: _toggleFavorite,
                  ),
                ),
              );
            },
          ),

          // Log Out
          _buildSettingsTile(
            context,
            icon: Icons.logout,
            title: 'Log Out',
            onTap: () => print('Log Out tapped'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6), // Spacing between items
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class FavoriteNewsPage extends StatelessWidget {
  final List<String> favoriteNews;
  final Function(String) toggleFavorite;

  FavoriteNewsPage({required this.favoriteNews, required this.toggleFavorite});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        itemCount: favoriteNews.length,
        itemBuilder: (context, index) {
          final article = favoriteNews[index];
          return ListTile(
            title: Text(article),
            trailing: IconButton(
              icon: Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              onPressed: () {
                toggleFavorite(article); // Toggle favorite status
                Navigator.pop(context); // Go back to settings page after toggling
              },
            ),
          );
        },
      ),
    );
  }
}
