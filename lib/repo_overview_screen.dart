import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../model/repo.dart';
import '../widgets/repo_item.dart';

class ReposOverviewScreen extends StatefulWidget {
  const ReposOverviewScreen({super.key});

  @override
  ReposOverviewScreenState createState() => ReposOverviewScreenState();
}

class ReposOverviewScreenState extends State<ReposOverviewScreen> {
  late bool _isLastPage;

  /// The page number that is yet to be initialized.
  late int _pageNumber;
  late bool _error;
  late bool _loading;
  final int _numberOfReposPerRequest = 10;
  late List<Repo> _repos;
  final int _nextPageTrigger = 3;

  @override
  void initState() {
    super.initState();
    _pageNumber = 0;
    _repos = [];
    _isLastPage = false;
    _loading = true;
    _error = false;
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await get(
        Uri.parse(
            "https://api.github.com/users/freeCodeCamp/repos?page=$_pageNumber&per_page=$_numberOfReposPerRequest"),
      );
      List responseList = json.decode(response.body);
      List<Repo> repoList = responseList
          .map((data) => Repo(
              data['name'],
              data['description'] ?? "Description not available",
              data['stargazers_count'] ?? 0))
          .toList();

      setState(() {
        _isLastPage = repoList.length < _numberOfReposPerRequest;
        _loading = false;
        _pageNumber = _pageNumber + 1;
        _repos.addAll(repoList);
      });
    } catch (e) {
      print("error --> $e");
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  Widget errorDialog({required double size}) {
    return SizedBox(
      height: 180,
      width: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'An error occurred when fetching the posts.',
            style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w500,
                color: Colors.black),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = false;
                  fetchData();
                });
              },
              child: Text(
                "Retry",
                style: TextStyle(
                    fontSize: 20, color: Theme.of(context).colorScheme.primary),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Repositories"),
        centerTitle: true,
      ),
      body: buildReposView(),
    );
  }

  Widget buildReposView() {
    if (_repos.isEmpty) {
      if (_loading) {
        return const Center(
            child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        ));
      } else if (_error) {
        return Center(child: errorDialog(size: 20));
      }
    }
    return ListView.builder(
        itemCount: _repos.length + (_isLastPage ? 0 : 1),
        itemBuilder: (context, index) {
          if (index == _repos.length - _nextPageTrigger) {
            fetchData();
          }
          if (index == _repos.length) {
            if (_error) {
              return Center(child: errorDialog(size: 15));
            } else {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ));
            }
          }
          final Repo repo = _repos[index];
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: RepoItem(repo.name, repo.description, repo.stargazersCount),
          );
        });
  }
}
