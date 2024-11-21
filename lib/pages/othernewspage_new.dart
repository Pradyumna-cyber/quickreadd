import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'package:quickreadd/pages/homepage.dart';
import 'package:url_launcher/url_launcher.dart';

class OthernewsPagenew extends StatefulWidget {
  const OthernewsPagenew({super.key});

  @override
  State<OthernewsPagenew> createState() => _OthernewsPagenewState();
}

class _OthernewsPagenewState extends State<OthernewsPagenew> {
  final Set<int> _selectedIndices = {};

  Set<String> selectedChips = {};
  final Set<String> likedArticles = {};  // Store liked articles by URL
  final List<String> _chipOptions = [
    'Tesla', 'Apple', 'Tech News', 'Fashion', 'Cinematic', 'Games', 'AI', 'Business',
    'Crime', 'Domestic', 'Education', 'Entertainment', 'Environment', 'Food', 'Health',
    'Lifestyle', 'Other', 'Politics', 'Science', 'Sports', 'Technology', 'Tourism', 'World',
  ];

  int visibleChipCount = 7;
  bool showAllChips = false;
  String selectedCategory = ""; // To store the selected category name

  String apiKey = 'ea01367e3da24cc5b9532cf8c5bfc0f7';
  List usHeadlines = [];
  List<dynamic> allArticles = [];

  @override
  void initState() {
    super.initState();
    fetchUSHeadlines();
    _loadLikedArticles();
  }

  Future<void> fetchUSHeadlines() async {
    try {
      final url =
          'https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=$apiKey';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List fetchedHeadlines = json.decode(response.body)['articles'];
        setState(() {
          usHeadlines = fetchedHeadlines
              .where((article) => isValidArticle(article))
              .toList();
          allArticles = List.from(usHeadlines);
        });
      } else {
        print('Error fetching US headlines: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error fetching US headlines: $e');
    }
  }
  Future<void> _loadLikedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      likedArticles.addAll(prefs.getStringList('likedArticles')?.toSet() ?? {});
    });
  }

  // Save liked articles to SharedPreferences
  Future<void> _saveLikedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('likedArticles', likedArticles.toList());
  }

  // Toggle favorite status for articles
  void _toggleFavorite(String articleUrl) {
    setState(() {
      if (likedArticles.contains(articleUrl)) {
        likedArticles.remove(articleUrl);  // Remove from favorites
      } else {
        likedArticles.add(articleUrl);  // Add to favorites
      }
    });
    _saveLikedArticles();  // Save the updated list to SharedPreferences
  }

  Future<void> fetchChipNews(String category) async {
    try {
      String url;
      if (category.toLowerCase() == 'tesla') {
        url =
        'https://newsapi.org/v2/everything?q=tesla&from=2024-10-20&sortBy=publishedAt&apiKey=$apiKey';
      } else if (category.toLowerCase() == 'apple') {
        url =
        'https://newsapi.org/v2/everything?q=apple&from=2024-11-19&to=2024-11-19&sortBy=popularity&apiKey=141b96c61b214ef7a62dafaff0256704';
      } else {
        String baseApiUrl = 'https://newsdata.io/api/1/news';
        String apiKey = 'pub_59676e06915292c01f3c97a6e0ca6fe77522f';
        url =
        '$baseApiUrl?apikey=$apiKey&q=$category&country=in&language=en&category=${category.toLowerCase()}';
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List fetchedArticles;
        if (category.toLowerCase() == 'tesla' || category.toLowerCase() == 'apple') {
          fetchedArticles = json.decode(response.body)['articles'];
        } else {
          fetchedArticles = json.decode(response.body)['results'];
        }

        setState(() {
          List validArticles = fetchedArticles
              .where((article) => isValidArticle(article))
              .toList();

          allArticles = [
            ...validArticles,
            ...allArticles.where((article) =>
            !validArticles.any((newArticle) => newArticle['link'] == article['link'])),
          ];
        });
      } else {
        print('API Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error fetching $category news: $e');
    }
  }

  bool isValidArticle(dynamic article) {
    return article != null &&
        article['url'] != null &&
        article['title'] != null &&
        article['content'] != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        shadowColor: Colors.redAccent.withOpacity(0.5),
        title: const Text('News Categories', style: TextStyle(color: Colors.white)),
        centerTitle: true,

        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => NewsPage()));
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 10.0,
              runSpacing: 15.0,
              children: List<Widget>.generate(
                showAllChips ? _chipOptions.length : visibleChipCount,
                    (int index) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: ChoiceChip(
                      key: ValueKey<int>(index),
                      label: Text(_chipOptions[index]),
                      selected: _selectedIndices.contains(index),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedIndices.add(index);
                            selectedCategory = _chipOptions[index]; // Update selected category
                            fetchChipNews(_chipOptions[index]);
                          } else {
                            _selectedIndices.remove(index);
                          }
                        });
                      },
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _selectedIndices.contains(index)
                            ? Colors.black
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: const BorderSide(color: Colors.transparent),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          if (!showAllChips)
            TextButton(
              onPressed: () {
                setState(() {
                  showAllChips = true;
                });
              },
              child: const Text(
                'More',
                style: TextStyle(color: Colors.pink),
              ),
            ),
          const Divider(),
          // Display the selected category name above the news
          if (selectedCategory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'News for: $selectedCategory',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
            ),
          Expanded(
            child: allArticles.isEmpty
                ? ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    child: Container(
                      height: 100.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10.0,
                            spreadRadius: 1.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
                : ListView.builder(
              itemCount: allArticles.length,
              itemBuilder: (context, index) {
                final article = allArticles[index];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: article['urlToImage'] != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        article['urlToImage'],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                        : const Icon(Icons.image, size: 50),
                    title: Text(
                      article['title'] ?? 'No title available',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      article['description'] ?? 'No description available',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        likedArticles.contains(article['url'])
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          if (likedArticles.contains(article['url'])) {
                            likedArticles.remove(article['url']);
                          } else {
                            likedArticles.add(article['url']);
                          }
                        });
                      },
                    ),
                    onTap: () async {
                      final url = article['url'];
                      if (url != null) {
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
