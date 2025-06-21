import 'package:flutter/material.dart';
import 'package:guide_up/services/firebase_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId; //logged in user's id
  final String otherUserId; //id of the other user
  final bool isCurrentUserMentor; //is current user is a mentor
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    required this.isCurrentUserMentor,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final chatService _chatService = chatService();
  bool isLoading = true;
  final TextEditingController _messageController = TextEditingController();
  String? senderPhoto;
  String? receiverPhoto;

  @override
  void initState() {
    super.initState();
    _initializeChatRoom();
  }

  Future<void> _initializeChatRoom() async {
    setState(() {
      isLoading = true;
    });

    String mentorId = widget.isCurrentUserMentor ? widget.currentUserId : widget.otherUserId;
    String menteeId = widget.isCurrentUserMentor ? widget.otherUserId : widget.currentUserId;

    bool chatExists = await _chatService.chatRoomExists(menteeId, mentorId);
    if (!chatExists) {
      await _chatService.createChatRoom(menteeId, mentorId);
      print("Chatroom Created");
    } else {
      print("Chatroom Already Exists");
    }

    setState(() {
      isLoading = false;
    });
  }


  Future<void> _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      String senderId = widget.currentUserId;
      String receiverId = widget.isCurrentUserMentor ? widget.otherUserId : widget.otherUserId;
      await _chatService.sendMessage(senderId, receiverId, message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 244, 248, 1),  
      body: SafeArea(
        child: Column(
          children: [
            //name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              color: Colors.white,
              child: Text(
                widget.otherUserName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            //msgs
             Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder(
                      stream: _chatService.getMessages(widget.currentUserId, widget.otherUserId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        var messages = snapshot.data!.docs;

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            var message = messages[index].data() as Map<String, dynamic>;
                            bool isMe = message["senderId"] == widget.currentUserId;

                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                decoration: BoxDecoration(
                                  color: isMe ? const Color(0xFF457b9d) : Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(15),
                                    topRight: const Radius.circular(15),
                                    bottomLeft: Radius.circular(isMe ? 15 : 0),
                                    bottomRight: Radius.circular(isMe ? 0 : 15),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  message["message"],
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            //msg input
            Container(
              padding: const EdgeInsets.all(10),
               decoration: const BoxDecoration(
                color: Colors.white,
                 boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, -1),
                  )
                ],
               ),
               child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4F8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          border: InputBorder.none,
                        ),
                      ),
                    )
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF457b9d)),
                    onPressed: _sendMessage,
                  ),
                ],
               ),
            )
            /*Expanded(
              child: StreamBuilder(
                stream: _chatService.getMessages(widget.currentUserId, widget.otherUserId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var messages = snapshot.data!.docs;
        
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index].data() as Map<String, dynamic>;
                      bool isMe = message["senderId"] == widget.currentUserId;
        
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            message["message"],
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(hintText: "Type your message..."),
                    ),
                  ),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Color(0xFF457b9d)),
                  ),
                ],
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
