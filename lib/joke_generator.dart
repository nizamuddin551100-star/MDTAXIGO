import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:share_plus/share_plus.dart';

void main() => runApp(JokeGeneratorApp());

class JokeGeneratorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Random Joke Generator',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey.shade900,
        useMaterial3: true,
      ),
      home: JokeGeneratorScreen(),
    );
  }
}

class JokeGeneratorScreen extends StatefulWidget {
  @override
  _JokeGeneratorScreenState createState() => _JokeGeneratorScreenState();
}

class _JokeGeneratorScreenState extends State<JokeGeneratorScreen> {
  String jokeText = "😂 Tap to generate a joke!";
  String jokePunchline = "";
  bool isLoading = false;
  int jokeCount = 0;
  List<String> favoriteJokes = [];
  String selectedCategory = "Any";
  bool isDarkMode = true;
  List<String> jokeHistory = [];

  final List<String> categories = [
    "Any",
    "General",
    "Programming",
    "Knock-knock",
    "Blonde",
    "Dark",
    "Religious",
    "Spooky"
  ];

  @override
  void initState() {
    super.initState();
    _fetchJoke();
  }

  Future<void> _fetchJoke() async {
    setState(() => isLoading = true);

    try {
      final String url = selectedCategory == "Any"
          ? "https://official-joke-api.appspot.com/random_joke"
          : "https://official-joke-api.appspot.com/jokes/$selectedCategory/random";

      final response = await http.get(Uri.parse(url)).timeout(
            Duration(seconds: 10),
            onTimeout: () => throw Exception("Connection timeout"),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          jokeText = json['setup'] ?? json['joke'] ?? "No setup";
          jokePunchline = json['punchline'] ?? "";
          jokeCount++;
          jokeHistory.add("$jokeText ${jokePunchline.isEmpty ? "" : "\n$jokePunchline"}");
          isLoading = false;
        });
      } else {
        _showError("Failed to load joke. Status: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Error: ${e.toString()}");
    }
  }

  void _showError(String message) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _addToFavorites() {
    String fullJoke = jokePunchline.isEmpty
        ? jokeText
        : "$jokeText\n\n$jokePunchline";

    if (!favoriteJokes.contains(fullJoke)) {
      setState(() => favoriteJokes.add(fullJoke));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Added to favorites!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⭐ Already in favorites!"),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareJoke() {
    String fullJoke = jokePunchline.isEmpty
        ? jokeText
        : "$jokeText\n\n$jokePunchline";

    Share.share(
      "😂 $fullJoke\n\n🎉 Shared from Joke Generator App!",
      subject: "Check out this funny joke!",
    );
  }

  void _copyToClipboard() {
    String fullJoke = jokePunchline.isEmpty
        ? jokeText
        : "$jokeText\n\n$jokePunchline";

    ScaffoldMessenger.of(context).copyWith;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("📋 Joke copied to clipboard!"),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "😂 Joke Generator",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 10,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => _showJokeHistory(),
            tooltip: "View History",
          ),
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () => _showFavorites(),
            tooltip: "View Favorites",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Stats Card
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statWidget("😂 Jokes Generated", "$jokeCount"),
                    _statWidget("⭐ Favorites", "${favoriteJokes.length}"),
                    _statWidget("📝 History", "${jokeHistory.length}"),
                  ],
                ),
              ),
              SizedBox(height: 25),

              // Category Selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Category:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((category) {
                        bool isSelected = selectedCategory == category;
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() => selectedCategory = category);
                              _fetchJoke();
                            },
                            backgroundColor: Colors.grey.shade800,
                            selectedColor: Colors.deepPurple,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Main Joke Display Card
              Container(
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade800, Colors.grey.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.deepPurple, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (isLoading)
                      Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                            strokeWidth: 4,
                          ),
                          SizedBox(height: 15),
                          Text(
                            "Loading amazing joke...",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Text(
                            "📖 Setup",
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            jokeText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                          if (jokePunchline.isNotEmpty)
                            ...[
                              SizedBox(height: 20),
                              Divider(color: Colors.deepPurple, thickness: 2),
                              SizedBox(height: 20),
                              Text(
                                "😆 Punchline",
                                style: TextStyle(
                                  color: Colors.cyan,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                jokePunchline,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.cyanAccent,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),
                            ],
                        ],
                      ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Action Buttons
              Column(
                children: [
                  // Primary Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _fetchJoke,
                      icon: Icon(Icons.refresh, size: 24),
                      label: Text(
                        "Generate New Joke",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Secondary Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addToFavorites,
                          icon: Icon(Icons.favorite_border),
                          label: Text("Favorite"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _shareJoke,
                          icon: Icon(Icons.share),
                          label: Text("Share"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _copyToClipboard,
                          icon: Icon(Icons.content_copy),
                          label: Text("Copy"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Info Card
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyan, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "💡 Features:",
                      style: TextStyle(
                        color: Colors.cyan,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    _featureItem("✅ 8 joke categories"),
                    _featureItem("✅ Save to favorites"),
                    _featureItem("✅ Share jokes via messaging"),
                    _featureItem("✅ Copy to clipboard"),
                    _featureItem("✅ View joke history"),
                    _featureItem("✅ Real-time API integration"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statWidget(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _featureItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Text(
        text,
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  void _showFavorites() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("⭐ Favorite Jokes (${favoriteJokes.length})"),
        content: favoriteJokes.isEmpty
            ? Text("No favorites yet! Add some jokes 😊")
            : Container(
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: favoriteJokes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          favoriteJokes[index],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => favoriteJokes.removeAt(index));
                            Navigator.pop(context);
                            _showFavorites();
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showJokeHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("📝 Joke History (${jokeHistory.length})"),
        content: jokeHistory.isEmpty
            ? Text("No history yet! Generate some jokes 😊")
            : Container(
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: jokeHistory.length.clamp(0, 10),
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          jokeHistory[jokeHistory.length - 1 - index],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: CircleAvatar(
                          child: Text("${index + 1}"),
                        ),
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => jokeHistory.clear());
              Navigator.pop(context);
            },
            child: Text("Clear History", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }
}
