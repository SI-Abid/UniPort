import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user.dart';
import 'avatar.dart';

class PendingTeacherTile extends StatefulWidget {
  const PendingTeacherTile({
    super.key,
    required this.user,
    required this.selected,
    required this.trigger,
  });
  final List selected;
  final User user;
  final Function trigger;
  @override
  State<PendingTeacherTile> createState() => _PendingTeacherTileState();
}

class _PendingTeacherTileState extends State<PendingTeacherTile> {
  bool marked = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        widget.trigger();
        marked = !marked;
        if (marked) {
          widget.selected.add(widget.user.uid);
        } else {
          widget.selected.remove(widget.user.uid);
        }
        // print(widget.selected);
      }),
      child: Container(
        height: 70,
        margin: const EdgeInsets.fromLTRB(14, 6, 14, 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 5,
              spreadRadius: 0.5,
              offset: Offset(0, 1),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            marked
                ? const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  )
                : Avatar(messageSender: widget.user),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.user.teacherId}',
                    style: GoogleFonts.sen(
                      fontSize: 20,
                    )),
                Text(widget.user.name,
                    style: GoogleFonts.sen(
                      fontSize: 14,
                    )),
              ],
            ),
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 22,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(30, 24, 143, 121),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('${widget.user.initials}',
                      style: GoogleFonts.sen(
                        fontSize: 14,
                      )),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 22,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(30, 24, 143, 121),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${widget.user.department}',
                    style: GoogleFonts.sen(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
