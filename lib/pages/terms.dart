import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TermsAndConditionsPage extends StatefulWidget {
  @override
  _TermsAndConditionsPageState createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool _isAtBottom = false; // To track if the user has scrolled to the bottom
  bool _hasAccepted = false; // To track if the terms are already accepted
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAcceptanceStatus();

    // Add a listener to the ScrollController to detect when scrolled to the bottom
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent) {
        setState(() {
          _isAtBottom = true;
        });
      }
    });
  }

  Future<void> _loadAcceptanceStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasAccepted = prefs.getBool('hasAcceptedTerms') ?? false;
    });
  }

  Future<void> _acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAcceptedTerms', true);
    setState(() {
      _hasAccepted = true;
    });

    // Show a snackbar to confirm acceptance
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("You have accepted the Terms and Conditions."),
        duration: const Duration(seconds: 2),
      ),
    );

    // Optionally navigate to a new page after acceptance
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  "Terms and Conditions",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "1. Introduction",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Welcome to QuickRead. By using our app, you agree to abide by the following terms and conditions...",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                const Text(
                  "2. Privacy Policy",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "We value your privacy. Please review our privacy policy for more details on how we handle your data...",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                const Text(
                  "3. User Responsibilities",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Users are responsible for ensuring their actions on the app comply with these terms. Any misuse...",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                const Text(
                  "4. Modifications to the Terms",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "QuickRead reserves the right to modify these terms and conditions at any time. Continued use...",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                const Text(
                  "5. Limitation of Liability",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "We will not be liable for any indirect, special, incidental, or consequential damages arising from the use of the app...",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                const Text(
                  "6. Termination",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "We reserve the right to terminate your access to the app at any time if you violate the terms...",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                const Text(
                  "7. Governing Law",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "These terms shall be governed by and construed in accordance with the laws of your jurisdiction...",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                const Text(
                  "8. Contact Us",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "If you have any questions or concerns regarding these terms, feel free to contact us at...",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _hasAccepted
                  ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      "You have already accepted the Terms and Conditions.",
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
                  : (_isAtBottom ? _acceptTerms : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasAccepted
                    ? Colors.green
                    : (_isAtBottom ? Colors.green : Colors.grey),
              ),
              child: Text(
                _hasAccepted ? "Accepted" : "I Agree",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
