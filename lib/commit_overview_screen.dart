import 'package:flutter/material.dart';
import 'package:gitrepo/model/commit.dart';
import 'dart:convert';
import 'package:http/http.dart';

class LastCommitPage extends StatefulWidget {
  final String name;
  final String description;
  final int stargazersCount;

  const LastCommitPage(this.name, this.description, this.stargazersCount,
      {super.key});

  @override
  State<LastCommitPage> createState() => _LastCommitPageState();
}

class _LastCommitPageState extends State<LastCommitPage> {
  late Commit _commit;
  late bool _error;
  late bool _loading;

  @override
  void initState() {
    super.initState();
    _commit = Commit('', '', '');
    _loading = true;
    _error = false;
    fetchData();
  }

  Future<void> fetchData() async {
    String r = widget.name;
    try {
      final response = await get(
        Uri.parse(
            "https://api.github.com/repos/freeCodeCamp/$r/commits?page=0&per_page=1"),
      );
      List responseList = json.decode(response.body);
      Commit commit = Commit(
        responseList[0]['commit']['author']['name'] ?? "Author not available",
        responseList[0]['commit']['committer']['name'] ??
            "Committer not available",
        responseList[0]['commit']['message'] ?? "Message not available",
      );

      setState(() {
        _loading = false;
        _commit = commit;
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
        title: const Text("Last Commit"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: buildCommitView(),
    );
  }

  Widget buildCommitView() {
    if (_commit.author == '') {
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
    final commit = _commit;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.name,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  maxLines: 5,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                String.fromCharCode(9733) + widget.stargazersCount.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
            child: Text(
              widget.description,
              style: const TextStyle(
                fontSize: 15,
              ),
              overflow: TextOverflow.visible,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Author: ${commit.author}',
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Commiter: ${commit.committer}',
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Expanded(
                  child: Text(
                    'Commit Message: ${commit.message}',
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    maxLines: 20,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
