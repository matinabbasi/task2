import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class InfiniteScrollDemo extends StatefulWidget {
  const InfiniteScrollDemo({super.key});

  @override
  _InfiniteScrollDemoState createState() => _InfiniteScrollDemoState();
}

class _InfiniteScrollDemoState extends State<InfiniteScrollDemo> {
  List<dynamic> posts = [];
  int currentPage = 1;
  int itemsPerPage = 10;
  Dio dio = Dio();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchPosts();
  }

  final ScrollController _scrollController = ScrollController();

  _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // Scroll reached the bottom
      if (!isLoading) {
        setState(() {
          isLoading = true;
          currentPage++;
          _fetchPosts();
        });
      }
    }
  }

  Future<void> _fetchPosts() async {
    try {
      final response = await dio.get(
        'https://jsonplaceholder.typicode.com/posts',
        queryParameters: {
          '_page': currentPage,
          '_limit': itemsPerPage,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          posts.addAll(data);
        });

        // Simulate a delay to make the loader visible
        await Future.delayed(const Duration(seconds: 3));

        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      isLoading = false;
      throw Exception('Failed to load data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Scroll Demo with dio'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: posts.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < posts.length) {
            final post = posts[index];
            return ListTile(
              title: Text(post['title']),
              subtitle: Text(post['body']),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: InfiniteScrollDemo(),
  ));
}
