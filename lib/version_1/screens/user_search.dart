import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user.dart';

class MySearchDelegate extends SearchDelegate {
  final List<User> list;
  MySearchDelegate({required this.list});
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<User> suggestions = [];
    for (var user in list) {
      final name = user.name;
      final sid = user.studentId;
      final tid = user.teacherId;
      if (name.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(user);
      } else {
        if (sid != null && sid.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(user);
        }
        if (tid != null && tid.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(user);
        }
      }
    }
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: SizedBox(
            width: 35,
            height: 35,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 110, 110, 110),
                border: Border.fromBorderSide(
                  BorderSide(
                    color: suggestions[index].usertype == 'student'
                        ? Colors.green
                        : Colors.blue,
                    width: 2.5,
                  ),
                ),
              ),
              child: suggestions[index].photoUrl == null
                  ? Center(
                      child: Text(
                        suggestions[index].name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        suggestions[index].photoUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          title: Text(
            suggestions[index].name,
            style: GoogleFonts.sen(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            suggestions[index].studentId ?? suggestions[index].teacherId ?? '',
            style: GoogleFonts.sen(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: Container(
              alignment: Alignment.center,
              height: 22,
              width: 35,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 147, 114),
                borderRadius: BorderRadius.circular(10),
                border: const Border.fromBorderSide(
                  BorderSide(
                    color: Color.fromARGB(255, 141, 13, 13),
                    width: 1.5,
                  ),
                ),
              ),
              child: Text(suggestions[index].department ?? '')),
          onTap: () {
            Navigator.pushReplacementNamed(
              context,
              '/message',
              arguments: suggestions[index].toMessageSender(),
            );
          },
        );
      },
    );
  }
}
