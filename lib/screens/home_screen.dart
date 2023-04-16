import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clubhouse_clone/screens/call_screen.dart';
import 'package:clubhouse_clone/util/app_colors.dart';
import 'package:clubhouse_clone/widgets/action_tile.dart';
import 'package:clubhouse_clone/widgets/room_tile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  static const routeName = "/";
  final controller = TextEditingController();

  Future<String> createRoom() async {
    final currUser = FirebaseAuth.instance.currentUser;
    final doc = FirebaseFirestore.instance.collection("rooms").doc();
    await doc.set(
      {
        "host_uid": currUser?.uid,
        "host_email": currUser?.email,
      },
    );
    return doc.id;
  }

  Future<void> joinRoom({
    required String roomID,
    required BuildContext context,
  }) async {
    final doc =
        await FirebaseFirestore.instance.collection("rooms").doc(roomID).get();
    if (!doc.exists) {
      Fluttertoast.showToast(msg: "No rooms found!");
      return;
    }

    // ignore: use_build_context_synchronously
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CallScreen(callID: roomID),
      ),
    );
  }

  void buildJoinRoomModal(BuildContext context) {
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
                hintText: "Enter the roomID",
              ),
              onEditingComplete: () {
                joinRoom(
                  roomID: controller.value.text,
                  context: context,
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                joinRoom(
                  roomID: controller.value.text,
                  context: context,
                );
              },
              child: const Text("Find room"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "JoinIn",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout_outlined),
            tooltip: "logout",
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Row(
              children: [
                ActionTile(
                  backgroundColor: AppColors.callToActionBackground,
                  foregroundColor: AppColors.callToActionPrimary,
                  iconData: Icons.add_rounded,
                  label: "start room",
                  onPressed: () {
                    createRoom();
                  },
                ),
                ActionTile(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.onBackground,
                  onPressed: () {
                    buildJoinRoomModal(context);
                  },
                  label: "join room",
                  iconData: Icons.add_call,
                )
              ],
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
          StreamBuilder(
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final fetchedData = snapshot.data?.docs.reversed.toList();
              final userImage = FirebaseAuth.instance.currentUser?.photoURL;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final data = fetchedData![index];
                    final username = data["host_email"];

                    return RoomTile(
                      roomID: data.id,
                      roomName: data.data()["name"],
                      userImage: userImage,
                      username: username,
                    );
                  },
                  childCount: snapshot.data?.docs.length,
                ),
              );
            },
            stream: FirebaseFirestore.instance
                .collection("rooms")
                // .where(
                //   "host_uid",
                //   isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                // )
                .snapshots(),
          ),
        ],
      ),
    );
  }
}
