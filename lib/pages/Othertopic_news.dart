import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MaterialApp(
    home: OtherNewstopic(),
  ));
}

class OtherNewstopic extends StatefulWidget {
  const OtherNewstopic({Key? key}) : super(key: key);

  @override
  _OtherNewstopicState createState() => _OtherNewstopicState();
}

class _OtherNewstopicState extends State<OtherNewstopic> {
  late List<dynamic> _teslaNews = [];
  late List<dynamic> _appleNews = [];
  late List<dynamic> _USNews = [];
  late List<dynamic> _TechNews = [];

  @override
  void initState() {
    super.initState();
    _fetchTeslaNews();
    _fetchAppleNews();
    _fetchUSNews();
    _fetchtechcrunchNews();
  }

  Future<void> _fetchTeslaNews() async {
    // Tesla news API URL
    String teslaApiUrl = 'https://newsapi.org/v2/everything?q=tesla&from=2024-10-11&sortBy=publishedAt&apiKey=ea01367e3da24cc5b9532cf8c5bfc0f7';

    try {
      final http.Response response = await http.get(Uri.parse(teslaApiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _teslaNews = json.decode(response.body)['articles'];
        });
      } else {
        throw Exception('Failed to load Tesla news');
      }
    } catch (e) {
      print('Error fetching Tesla news: $e');
    }
  }

  Future<void> _fetchAppleNews() async {
    // Apple news API URL
    String appleApiUrl = 'https://newsapi.org/v2/everything?q=apple&from=2024-11-10&to=2024-11-10&sortBy=popularity&apiKey=ea01367e3da24cc5b9532cf8c5bfc0f7';

    try {
      final http.Response response = await http.get(Uri.parse(appleApiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _appleNews = json.decode(response.body)['articles'];
        });
      } else {
        throw Exception('Failed to load Apple news');
      }
    } catch (e) {
      print('Error fetching Apple news: $e');
    }
  }

  Future<void> _fetchUSNews() async {
    // US news API URL
    String usApiUrl = 'https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=ea01367e3da24cc5b9532cf8c5bfc0f7';

    try {
      final http.Response response = await http.get(Uri.parse(usApiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _USNews = json.decode(response.body)['articles'];
        });
      } else {
        throw Exception('Failed to load US headlines');
      }
    } catch (e) {
      print('Error fetching US headlines: $e');
    }
  }

  Future<void> _fetchtechcrunchNews() async {
    // TechCrunch news API URL
    String techCrunchApiUrl = 'https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=ea01367e3da24cc5b9532cf8c5bfc0f7';

    try {
      final http.Response response = await http.get(Uri.parse(techCrunchApiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _TechNews = json.decode(response.body)['articles'];
        });
      } else {
        throw Exception('Failed to load TechCrunch headlines');
      }
    } catch (e) {
      print('Error fetching TechCrunch headlines: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Topics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _buildNewsCategoryCard(
            context,
            title: 'Tesla News',
            iconPath: 'images/tesla.png',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsList(
                    newsList: _teslaNews,
                    category: 'Tesla',
                  ),
                ),
              );
            },
          ),
          _buildNewsCategoryCard(
            context,
            title: 'Apple News',
            iconPath: 'images/apple-logo.png',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsList(
                    newsList: _appleNews,
                    category: 'Apple',
                  ),
                ),
              );
            },
          ),
          _buildNewsCategoryCard(
            context,
            title: 'US Headlines',
            iconPath: 'images/apple-logo.png',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsList(
                    newsList: _USNews,
                    category: 'US Business',
                  ),
                ),
              );
            },
          ),
          _buildNewsCategoryCard(
            context,
            title: 'Tech Headlines',
            iconPath: 'images/apple-logo.png',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsList(
                    newsList: _TechNews,
                    category: 'TechCrunch',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCategoryCard(BuildContext context, {required String title, required String iconPath, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: ListTile(
          leading: Image.asset(iconPath, width: 36, height: 36),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        ),
      ),
    );
  }
}

class NewsList extends StatelessWidget {
  final List<dynamic> newsList;
  final String category;

  const NewsList({Key? key, required this.newsList, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List validNewsList = newsList.where((news) => news['urlToImage'] != null).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('$category News'),
      ),
      body: validNewsList.isEmpty
          ? const Center(child: Text('No news available', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))
          : ListView.builder(
        itemCount: validNewsList.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> news = validNewsList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetails(news: news),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.all(8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (news['urlToImage'] != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        news['urlToImage'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      news['title'] ?? '',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class NewsDetails extends StatefulWidget {
  final Map<String, dynamic> news;

  const NewsDetails({Key? key, required this.news}) : super(key: key);

  @override
  _NewsDetailsState createState() => _NewsDetailsState();
}

class _NewsDetailsState extends State<NewsDetails> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final news = widget.news;
    final description = news['description'] ?? '';
    final truncatedDescription = description.length > 100 ? '${description.substring(0, 100)}...' : description;

    return Scaffold(
      appBar: AppBar(
        title: Text(news['title'] ?? ''),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news['urlToImage'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  news['urlToImage'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
            const SizedBox(height: 10),
            Text(
              news['title'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _isExpanded ? description : truncatedDescription,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                _isExpanded ? 'Read less' : 'Read more',
                style: TextStyle(fontSize: 16, color: Colors.blue[700], fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final Uri url = Uri.parse(news['url'] ?? '');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: const Text('Read Full Article', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
