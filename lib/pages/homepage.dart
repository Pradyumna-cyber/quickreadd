import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:quickreadd/pages/othernewspage_new.dart';

import 'Othertopic_news.dart';
import 'categories.dart';
import 'fullnewspage.dart';
import 'profilepage.dart'; // Import Profile page file

// import 'package:location/location.dart';
int _selectedIndex = 0;

List<String> countries = [
  "Argentina",
  "Australia",
  "Austria",
  "Belgium",
  "Brazil",
  "Bulgaria",
  "Canada",
  "China",
  "Colombia",
  "Cuba",
  "Czech Republic",
  "Egypt",
  "France",
  "Germany",
  "Greece",
  "Hong Kong",
  "Hungary",
  "India",
  "Indonesia",
  "Ireland",
  "Israel",
  "Italy",
  "Japan",
  "Latvia",
  "Lithuania",
  "Malaysia",
  "Mexico",
  "Morocco",
  "Netherlands",
  "New Zealand",
  "Nigeria",
  "Norway",
  "Philippines",
  "Poland",
  "Portugal",
  "Romania",
  "Russia",
  "Saudi Arabia",
  "Serbia",
  "Singapore",
  "Slovakia",
  "Slovenia",
  "South Africa",
  "South Korea",
  "Sweden",
  "Switzerland",
  "Taiwan",
  "Thailand",
  "Turkey",
  "UAE",
  "Ukraine",
  "United Kingdom",
  "United States",
  "Venuzuela",
];

void navigateToProfile(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const Profile()),
  );
}

void naviagatetoNews(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const OtherNewstopic()),
  );
}

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late bool isConnected = false;
  late String selectedCountry = "us"; // Default is India
  late String selectedCategory;
  List<dynamic> newsArticles = [];
  bool isLoading = false;
  bool hasNoNews = false; // New flag to track if news is available
  int _selectedIndex = 0;
  // Country code mapping
   Map<String, String> countryCode = {
    "Argentina": "ar",
    "Australia": "au",
    "Austria": "at",
    "Belgium": "be",
    "Brazil": "br",
    "Bulgaria": "bg",
    "Canada": "ca",
    "China": "cn",
    "Colombia": "co",
    "Cuba": "cu",
    "Czech Republic": "cz",
    "Egypt": "eg",
    "France": "fr",
    "Germany": "de",
    "Greece": "gr",
    "Hong Kong": "hk",
    "Hungary": "hu",
    "India": "in",
    "Indonesia": "id",
    "Ireland": "ie",
    "Israel": "il",
    "Italy": "it",
    "Japan": "jp",
    "Latvia": "lv",
    "Lithuania": "lt",
    "Malaysia": "my",
    "Mexico": "mx",
    "Morocco": "ma",
    "Netherlands": "nl",
    "New Zealand": "nz",
    "Nigeria": "ng",
    "Norway": "no",
    "Philippines": "ph",
    "Poland": "pl",
    "Portugal": "pt",
    "Romania": "ro",
    "Russia": "ru",
    "Saudi Arabia": "sa",
    "Serbia": "rs",
    "Singapore": "sg",
    "Slovakia": "sk",
    "Slovenia": "si",
    "South Africa": "za",
    "South Korea": "kr",
    "Sweden": "se",
    "Switzerland": "ch",
    "Taiwan": "tw",
    "Thailand": "th",
    "Turkey": "tr",
    "UAE": "ae",
    "Ukraine": "ua",
    "United Kingdom": "gb",
    "United States": "us",
    "Venuzuela": "ve",
  };
  Map<String, dynamic>? weatherData;

  // API Key for NewsAPI
  final String apiKey = "ea01367e3da24cc5b9532cf8c5bfc0f7";

  @override
  void initState() {
    super.initState();
    selectedCategory = 'general';
    fetchWeatherForCountry('us');
    checkInternetConnectivity().then((connected) {
      setState(() {
        isConnected = connected;
        if (isConnected) {
          fetchNewsForCountry("us"); // Explicitly fetch Indian news at start
        }
      });
    });

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        isConnected = result != ConnectivityResult.none;
        if (isConnected) {
          fetchNewsForCountry(selectedCountry);
        } else {
          setState(() {
            newsArticles.clear();
          });
        }
      });
    });
  }

  // Add the missing checkInternetConnectivity method
  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Background color for the bottom nav container
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.transparent, // Transparent to show container color
        selectedItemColor: Colors.red, // Color for selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        showUnselectedLabels: true, // Display labels for unselected items
        type: BottomNavigationBarType.fixed, // Ensures all items are displayed
        elevation: 0, // Remove BottomNavigationBar elevation for custom shadow
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(
              Icons.home,
              size: 30, // Larger size for active icon
              color: Colors.red, // Color to match the selected item color
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(
              Icons.favorite,
              size: 30, // Larger size for active icon
              color: Colors.red,
            ),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(
              Icons.person,
              size: 30, // Larger size for active icon
              color: Colors.red,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Add the _onItemTapped method
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigation logic
    switch (index) {
      case 0:
        // Navigate to the first page or show content for index 0
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const NewsPage()));
        break;
      case 1:
        // Navigate to the second page or show content for index 1
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const OthernewsPagenew()));
        break;
      case 2:
        // Navigate to the third page or show content for index 2
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SettingsPage()));
        break;
      default:
        // Handle any other cases if needed
        break;
    }
  }

// Add the missing _showCategoryDialog method
  void _showCategoryDialog(BuildContext context) {
    final List<Map<String, IconData>> categories = [
      {'General': Icons.public},
      {'Business': Icons.business_center},
      {'Entertainment': Icons.movie},
      {'Health': Icons.local_hospital},
      {'Science': Icons.science},
      {'Sports': Icons.sports_soccer},
      {'Technology': Icons.devices},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(
              maxHeight: 500, // Set the maximum height of the dialog box
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  const Text(
                    "Select Category",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.blueGrey, thickness: 1.2),
                  const SizedBox(height: 10),
                  // Category List with scrolling if necessary
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(categories.length, (index) {
                          String category = categories[index].keys.first;
                          IconData icon = categories[index][category]!;
                          return ListTile(
                            leading: Icon(
                              icon,
                              color: Colors.blueAccent,
                            ),
                            title: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                selectedCategory = category.toLowerCase();
                              });
                              fetchNewsForCountry(selectedCountry);
                            },
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Future<void> fetchNewsForCountry(String countryCode) async {
    if (!isConnected) return;

    setState(() {
      isLoading = true;
      hasNoNews = false; // Reset the no-news flag
    });

    try {
      final url = Uri.parse(
          'https://newsapi.org/v2/top-headlines?country=$countryCode&category=$selectedCategory&apiKey=$apiKey');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          newsArticles = data['articles'] ?? [];
          selectedCountry = countryCode;
          hasNoNews = newsArticles.isEmpty; // Set flag if no articles
        });
      } else {
        throw Exception("Failed to load news");
      }
    } catch (e) {
      print("Error fetching news: $e");
      Fluttertoast.showToast(
        msg: 'Failed to load news. Please try again.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() {
        hasNoNews = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> fetchWeatherForCountry(String countryCode) async {
    final apiKey = 'b3fd031d9da8eb1f72fdfdd5beda63ec'; // Replace with your actual API key
    final countryName = this.countryCode.entries.firstWhere(
          (entry) => entry.value == countryCode,
      orElse: () => const MapEntry('Unknown Country', ''),
    ).key;

    if (countryName == 'Unknown Country') {
      Fluttertoast.showToast(
        msg: 'Invalid country code',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$countryName&units=metric&appid=$apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          weatherData = data; // Store weather data in a state variable
        });
      } else {
        throw Exception("Failed to fetch weather data");
      }
    } catch (e) {
      print("Error fetching weather: $e");
      Fluttertoast.showToast(
        msg: 'Failed to load weather data. Please try again.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily, // Use Poppins for modern font styling.
    ),
    home: Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: isConnected
          ? SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildNewsList(),
                  ),
                ],
              ),
            )
          : _buildNoConnectionView(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.redAccent,
        child: const Icon(
          Icons.video_camera_back_rounded,
          color: Colors.white,
        ),
      ),
    ),);
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "News",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            DateFormat('MMMM d').format(DateTime.now()),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      // Text(
                      //   countryCode.entries
                      //       .firstWhere(
                      //         (entry) => entry.value == selectedCountry,
                      //     orElse: () => MapEntry('Unknown', selectedCountry),
                      //   )
                      //       .key,
                      //   style: const TextStyle(
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.deepOrange,
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 20), // Add spacing between date and weather
                  isLoading
                      ? const CircularProgressIndicator()
                      : weatherData != null && weatherData!.isNotEmpty
                      ? Column(
                    children: [
                      buildWeatherUI(weatherData, selectedCountry),
                    ],

                  )
                      : const Text(
                    'Weather information will be shown here.',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
          )

          ,
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                title: "Select Country",
                icon: Icons.public,
                onPressed: () => _showCountryDialog(context),
                gradient: [Colors.blue.shade200, Colors.blue.shade600],
              ),
              _buildActionButton(
                title: "Categories",
                icon: Icons.category,
                onPressed: () => _showCategoryDialog(context),
                gradient: [
                  Colors.deepOrange.shade200,
                  Colors.deepOrange.shade600
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Rest of the existing methods remain the same...
  // (_buildActionButton, _buildNewsList, _buildNoConnectionView, _showCountryDialog)

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(colors: gradient),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(title, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsList() {
    return LiquidPullToRefresh(
      onRefresh: () => fetchNewsForCountry(selectedCountry),
      showChildOpacityTransition: true, // Adds a fade effect when pulling down
      height: 100.0, // Sets the height of the pull-down effect
      backgroundColor: Colors
          .blue[100], // Sets the background color of the refresh indicator
      color: Colors.blue, // Sets the color of the loading indicator
      child: ListView.builder(
        itemCount: newsArticles.length,
        itemBuilder: (context, index) {
          final article = newsArticles[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullNewsPage(news: article),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article['urlToImage'] != null)
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          article['urlToImage'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'images/error-404.png',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            article['description'] ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                article['source']['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
                                ),
                              ),
                              if (article['publishedAt'] != null)
                                Text(
                                  DateFormat('MMM d, y').format(
                                    DateTime.parse(article['publishedAt']),
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoConnectionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.signal_wifi_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Internet Connection',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }



  void _showCountryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(
              maxHeight: 400, // Set the maximum height for the dialog
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    "Select Country",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    thickness: 1.5,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(height: 16),
                  // Country List with scrolling
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(countryCode.length, (index) {
                          String countryName = countryCode.keys.elementAt(index);
                          String code = countryCode.values.elementAt(index).toLowerCase();
                          return ListTile(
                            leading: CountryFlag.fromCountryCode( // Use the named constructor
                              code, // Pass the country code as a string
                              height: 24,  // Adjust the height of the flag
                              width: 32,   // Adjust the width of the flag
                            ),
                            title: Text(
                              countryName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: selectedCountry == code ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            selected: selectedCountry == code,
                            selectedTileColor: Colors.blue[50],
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                selectedCountry = code;
                              });
                              fetchNewsForCountry(code);
                              fetchWeatherForCountry(code);
                            },
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Close Button
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Close",
                        style: TextStyle(fontSize: 16,color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }







  Widget buildWeatherUI(Map<String, dynamic>? weatherData, String countryName) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.blueGrey[900], // Background color for better contrast
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          if (weatherData != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dynamic date text
                Text(
                  countryCode.entries
                      .firstWhere(
                        (entry) => entry.value == selectedCountry,
                    orElse: () => MapEntry('Unknown', selectedCountry),
                  )
                      .key,
                  style:  const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Text(
                //   DateFormat('EEE, d MMM').format(DateTime.now()), // Current date
                //   style: const TextStyle(
                //     fontSize: 20,
                //     fontWeight: FontWeight.w500,
                //     color: Colors.white,
                //   ),
                // ),
                const SizedBox(width: 15), // Spacer

                // Vertical divider
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 15), // Spacer

                // Weather icon
                Image.network(
                  'http://openweathermap.org/img/wn/${weatherData['weather'][0]['icon']}@2x.png',
                  height: 40,
                  width: 40,
                ),
                const SizedBox(width: 15), // Spacer

                // Temperature text
                Text(
                  '${weatherData['main']['temp']}°',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          if (weatherData == null)
            const Text(
              'Loading...',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
        ],
      ),
    );
  }


}
