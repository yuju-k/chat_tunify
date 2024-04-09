import 'package:chat_tunify/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart' as rtdb;
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final rtdb.DatabaseReference databaseRef =
      rtdb.FirebaseDatabase.instance.ref();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String userEmail = FirebaseAuth.instance.currentUser!.email!;
  List<Map<String, dynamic>> chatList = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadChatList();
  }

  void loadChatList() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Cloud Firestore에서 현재 사용자의 채팅방 목록을 가져옵니다.
      DocumentSnapshot userChatRoomsSnapshot =
          await firestore.collection('user_chat_rooms').doc(userEmail).get();

      if (userChatRoomsSnapshot.exists) {
        Map<String, dynamic> userChatRooms =
            userChatRoomsSnapshot.data() as Map<String, dynamic>;

        List<Map<String, dynamic>> loadedChatList = [];
        for (String chatRoomId in userChatRooms.keys) {
          //key값을 사용해서 채팅방 정보를 가져옴
          if (userChatRooms[chatRoomId] == true) {
            //chatRoomId가 true인 경우에만 채팅방 정보를 가져옴
            try {
              // 채팅방 정보 가지고 오기, chat_rooms => chatRoomId (realtime database)
              rtdb.DataSnapshot chatRoomSnapshot = await databaseRef
                  .child('chat_rooms')
                  .child(chatRoomId)
                  .once()
                  .then((value) => value.snapshot);

              Map<String, dynamic> chatRoomDetails =
                  Map<String, dynamic>.from(chatRoomSnapshot.value as Map);

              // 현재 사용자를 제외한 다른 참가자의 이메일을 찾습니다.
              String friendEmail = chatRoomDetails['userEmails']
                  .firstWhere((email) => email != userEmail, orElse: () => '');

              if (friendEmail.isEmpty) {
                continue;
              }

              // Firestore에서 친구의 프로필을 가져옵니다.
              var friendProfile = await firestore
                  .collection('user_profile')
                  .where('email', isEqualTo: friendEmail)
                  .get();

              if (friendProfile.docs.isNotEmpty) {
                var friendData = friendProfile.docs.first.data();
                String friendName = friendData['name'] ?? 'Unknown';
                String friendImageUrl = friendData['imageUrl'] ?? '';
                String friendUid = friendData['uid'] ?? '';

                // 채팅방 정보를 loadedChatList에 추가합니다.
                loadedChatList.add({
                  'roomId': chatRoomId,
                  'roomName': friendName,
                  'friendEmail': friendEmail,
                  'friendImageUrl': friendImageUrl,
                  'friendUid': friendUid,
                  'lastMessage': chatRoomDetails['last_message'] ?? '',
                });
              }
            } catch (e) {
              // Handle exceptions for each chat room processing
              //print('Error processing a chat room: $e');
            }
          }
        }

        setState(() {
          chatList = loadedChatList;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle exceptions for the entire chat list loading process
      //print('Error loading chat list: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대화목록'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : chatList.isNotEmpty
              ? ListView.builder(
                  itemCount: chatList.length,
                  itemBuilder: (context, index) {
                    var chatRoom = chatList[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: chatRoom['friendImageUrl'] != null &&
                                chatRoom['friendImageUrl'].isNotEmpty
                            ? NetworkImage(chatRoom['friendImageUrl'])
                                as ImageProvider<Object>?
                            : const AssetImage(
                                'assets/images/default_profile.png'),
                      ),
                      title: Text(chatRoom['roomName'] ?? 'No name'),
                      subtitle: Text(
                        chatRoom['lastMessage'].length > 20
                            ? '${chatRoom['lastMessage'].substring(0, 20)}...'
                            : chatRoom['lastMessage'],
                      ),
                      onTap: () {
                        //채팅방으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatRoomPage(
                              name: chatRoom['roomName'],
                              email: chatRoom['friendEmail'],
                              uid: chatRoom['friendUid'],
                              roomId: chatRoom['roomId'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              : const Center(
                  child: Text('대화방이 없습니다.'),
                ),
    );
  }
}
