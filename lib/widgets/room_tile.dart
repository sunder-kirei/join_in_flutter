import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../screens/call_screen.dart';
import '../util/app_colors.dart';

class RoomTile extends StatelessWidget {
  RoomTile({
    super.key,
    required this.userImage,
    required this.username,
    required this.roomID,
    this.roomName,
  });

  final String roomID;
  final String? roomName;
  final String? userImage;
  final String username;

  final controller = TextEditingController();

  Future<void> copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: roomID));
    Fluttertoast.showToast(
      msg: "Room ID copied!",
    );
  }

  Future<void> deleteRoom() async {
    FirebaseFirestore.instance.collection("rooms").doc(roomID).delete();
  }

  Future<void> changeName({required String name}) async {
    FirebaseFirestore.instance.collection("rooms").doc(roomID).set(
      {
        "name": name,
      },
      SetOptions(merge: true),
    );
  }

  void buildOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: username == FirebaseAuth.instance.currentUser?.email
                  ? () {
                      deleteRoom();
                      Navigator.of(context).pop();
                    }
                  : null,
              icon: const Icon(Icons.delete_forever_rounded),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              label: const Text("Delete room"),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: username == FirebaseAuth.instance.currentUser?.email
                  ? () {
                      Navigator.of(context).pop();
                      buildRenameModal(context);
                    }
                  : null,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onBackground,
              ),
              icon: const Icon(Icons.edit),
              label: const Text("Rename room"),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                copyToClipboard();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onBackground,
              ),
              icon: const Icon(Icons.copy),
              label: const Text("Copy to clipboard"),
            ),
          ],
        ),
      ),
    );
  }

  void buildRenameModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 40,
          bottom: MediaQuery.of(
            context,
          ).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Enter a name",
              ),
              onEditingComplete: () {
                changeName(name: controller.value.text);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                changeName(name: controller.value.text);
                Navigator.of(context).pop();
              },
              child: const Text("Rename room"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CallScreen(callID: roomID),
          ),
        );
      },
      onLongPress: copyToClipboard,
      child: Card(
        surfaceTintColor: Theme.of(
          context,
        ).colorScheme.secondary,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 20,
                child: Initicon(
                  text: username,
                  size: 40,
                  style: TextStyle(
                    fontFamily: GoogleFonts.nunito().fontFamily,
                  ),
                  backgroundColor: AppColors.fontSecondary,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roomName ?? username,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: 11,
                        ),
                  ),
                  Text(
                    roomID,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  buildOptionsModal(context);
                },
                icon: const Icon(Icons.more_vert),
                style: Theme.of(context).iconButtonTheme.style,
                tooltip: "Options",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
