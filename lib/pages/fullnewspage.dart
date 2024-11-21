import 'dart:typed_data'; // Only required for Uint8List
import 'dart:io'; // For File operations
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'; // For path_provider
import 'package:share_plus/share_plus.dart';

import 'package:url_launcher/url_launcher.dart';

class FullNewsPage extends StatefulWidget {
  final Map<String, dynamic> news;

  const FullNewsPage({Key? key, required this.news}) : super(key: key);

  @override
  _FullNewsPageState createState() => _FullNewsPageState();
}

class _FullNewsPageState extends State<FullNewsPage> {
  bool _isExpanded = false; // Track whether the content is expanded
  bool _isDescriptionExpanded =
  false; // Track whether the description is expanded

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.news['title'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _shareNews(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.news['urlToImage'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  widget.news['urlToImage'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300, // Increased height for better impact
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : Container(
                      width: double.infinity,
                      height: 300,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                              (progress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(
              widget.news['title'] ?? '',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            // Description with "Read More" toggle
            Text(
              _isDescriptionExpanded ||
                  (widget.news['description'] ?? '').length <= 100
                  ? (widget.news['description'] ?? '')
                  : (widget.news['description'] ?? '').substring(0, 100) +
                  '...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (widget.news['description'] != null &&
                widget.news['description'].length > 100)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isDescriptionExpanded = !_isDescriptionExpanded;
                  });
                },
                child: Text(
                  _isDescriptionExpanded ? 'Read Less' : 'Read More',
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () async {
                final Uri uri = Uri.parse(widget.news['url']);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not launch ${widget.news['url']}')),
                  );
                }
              },
              icon: const Icon(Icons.open_in_browser, color: Colors.white),
              label: const Text(
                'Read Full Article',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: Colors.blueAccent.withOpacity(0.4),
                elevation: 4,
              ),
            )

          ],
        ),
      ),
    );
  }

  void _shareNews(BuildContext context) async {
    try {
      final http.Response response =
      await http.get(Uri.parse(widget.news['urlToImage']));
      final Uint8List bytes = response.bodyBytes;

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/image.jpg').create();
      await file.writeAsBytes(bytes);

      final String text = '${widget.news['title']}\n${widget.news['url']}';
      await Share.shareFiles([file.path],
          text: text, subject: widget.news['title']);
    } catch (e) {
      print('Error sharing news: $e');
    }
  }
}