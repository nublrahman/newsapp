import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'article.dart';
import 'news_detail_page.dart';

class NewsList extends StatefulWidget {
  const NewsList({Key? key}) : super(key: key);

  @override
  _NewsListState createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  Future<List<Article>?>? newsData;

  @override
  void initState() {
    super.initState();
    newsData = fetchNews();
  }

  Future<List<Article>?> fetchNews() async {
    const apiKey = '7f48f104593a45949bad59167b380cee';
    final response = await http.get(
      Uri.parse(
        'https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final articles = data['articles'];
      return List<Article>.from(articles
          .map((article) => Article.fromJson(article))
          .where((article) => article.urlToImage != null));
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      body: FutureBuilder<List<Article>?>(
        future: newsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
              ),
            );
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final article = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDetailPage(article: article),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      leading: Image.network(
                        article.urlToImage!,
                        width: 100.0,
                        height: 100.0,
                      ),
                      title: Text(
                        article.title ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text('No data available.', 
              style: TextStyle(color: Colors.white)),
            );
          }
        },
      ),
    );
  }
}
