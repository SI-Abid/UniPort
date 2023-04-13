import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uniport/version_1/models/models.dart';
import 'package:uniport/version_1/providers/chat_controller.dart';
import 'package:uniport/version_1/screens/group_chat_screen.dart';

import '../widgets/widgets.dart';

class AssignedGroupScreen extends StatefulWidget {
  static const routeName = '/assigned-group-screen';
  const AssignedGroupScreen({super.key});

  @override
  State<AssignedGroupScreen> createState() => _AssignedGroupScreenState();
}

class _AssignedGroupScreenState extends State<AssignedGroupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppTitle(title: 'Groups'),
        leadingWidth: 24,
        iconTheme: IconThemeData(color: Colors.teal.shade800),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Batch List',
              style: GoogleFonts.sen(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.teal.shade800,
              ),
            ),
            Divider(
              color: Colors.teal.shade800,
              thickness: 0.5,
            ),
            Consumer(
              builder: (context, ref, child) {
                // final user = userProvider.user!;
                return StreamBuilder<List<GroupLastMessage>>(
                  stream: ref
                      .watch(chatControllerProvider)
                      .groupLastMessageStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    final tiles = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: tiles.length,
                      itemBuilder: (context, index) {
                        return GroupChatTile(
                          groupId: tiles[index].message.chatId,
                          sections: tiles[index].sections,
                          lastMsg: tiles[index].message,
                          sender: tiles[index].sender,
                          batch: tiles[index].batch,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GroupChatTile extends StatelessWidget {
  const GroupChatTile({
    super.key,
    required this.groupId,
    required this.sections,
    required this.lastMsg,
    required this.sender,
    required this.batch,
  });

  final String groupId;
  final List<String> sections;
  final Message lastMsg;
  final UserModel sender;
  final String batch;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GroupChatScreen(
              groupId: groupId,
              title: 'Advising $batch ${sections.join('+')}',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.teal.shade800,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text(
                batch,
                style: GoogleFonts.sen(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          title: Text(
            'Advising $batch ${sections.join('+')}',
            style: GoogleFonts.sen(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade900,
            ),
          ),
          subtitle: Text(
            '${lastMsg.sender == FirebaseAuth.instance.currentUser!.uid ? 'You: ' : '${sender.firstName!}: '}${lastMsg.type == MessageType.text ? lastMsg.content : 'Image'}',
            softWrap: true,
            maxLines: 1,
            style: GoogleFonts.sen(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ),
    );
  }
}
