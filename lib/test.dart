
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uniport/version_1/models/user.dart';
import 'package:uniport/version_1/services/helper.dart';

Future<void> main(List<String> args) async {
  await initiate();
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Test',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const SearchUser(),
    );
  }
}

class SearchUser extends StatefulWidget {
  const SearchUser({super.key});

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  late Widget _body;
  final List<UserModel> list = [];
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        list.add(UserModel.fromJson(doc.data() as Map<String, dynamic>));
      }
      if (kDebugMode) {
        print(list.length);
      }
    });
    _body = ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text('User ${index + 1}'),
          subtitle: Text('User ${index + 1}'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: _isSearching
            ? TextField(
                onSubmitted: update,
                onChanged: update,
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search by name or ID',
                  hintStyle: TextStyle(color: Colors.white),
                  border: UnderlineInputBorder(),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              )
            : const Text('Chat'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  if (_searchController.text.isNotEmpty) {
                    _searchController.clear();
                  } else {
                    _isSearching = !_isSearching;
                  }
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: _body,
      ),
    );
  }

  void update(String value) async {
    _body = const Center(
      child: CircularProgressIndicator(),
    );
    setState(() {});
    await getFacult(value);
    setState(() {});
  }

  Future<void> getFacult(String name) async {
    final matchList = <UserModel>[];
    for (var user in list) {
      if (user.name.toLowerCase().contains(name.toLowerCase())) {
        matchList.add(user);
      }
    }
    _body = ListView.builder(
      itemCount: matchList.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(matchList[index].photoUrl.toString()),
          ),
          title: Text(matchList[index].name),
          subtitle: Text(matchList[index].department.toString()),
        );
      },
    );
  }
}
