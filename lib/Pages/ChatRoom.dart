import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:uuid/uuid.dart';

import '../Services/ItemService.dart';
import '../Services/TransactionService.dart';
import 'SuccessPage.dart';

class ChatRoom extends StatefulWidget {
  final String chat_id;
  final String item_id;
  final String current_id;
  final String other_id;

  const ChatRoom(
      {super.key,
      required this.chat_id,
      required this.item_id,
      required this.current_id,
      required this.other_id});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

const SYSTEM_ID = "RECLOSET_SYSTEM";

class _ChatRoomState extends State<ChatRoom> {
  final List<types.Message> _messages = [];
  bool isOfferIntiated = false;

  void initChat() {
    final CollectionReference chatsCollection =
        FirebaseFirestore.instance.collection('item_chats');
    final CollectionReference messagesCollection =
        FirebaseFirestore.instance.collection('messages');

    // Check if the chat room already exists
    chatsCollection
        .doc(widget.chat_id)
        .get()
        .then((chatDoc) async {
          print("Does it exist?");
          print(widget.chat_id);
          print(chatDoc.exists);

          if (chatDoc.exists) {
            // Chat room exists, proceed with fetching messages and setting up listeners

            // Fetch existing messages for the chat room
            messagesCollection
                .where('chat_id', isEqualTo: widget.chat_id)
                .orderBy('createdAt')
                .snapshots()
                .listen((QuerySnapshot snapshot) {
              List<QueryDocumentSnapshot> documents = snapshot.docs;
              // Process fetched messages and update your UI
              // e.g., update a message list or chat bubble widget
              for (var doc in documents) {
                Map<String, dynamic> author = doc['author'];
                String text = doc['text'];
                int createdAt = doc['createdAt'];
                String type = doc['type'];
                print("listen: ");
                print(doc);

                if (type == 'system') {
                  final systemMessage = types.SystemMessage(
                    createdAt: createdAt,
                    id: doc.id,
                    text: text,
                  );
                  _addMessage(systemMessage);
                  isOfferIntiated = true;
                } else {
                  final textMessage = types.TextMessage(
                    author: types.User(
                        id: author['id'],
                        imageUrl:
                            'https://api.dicebear.com/6.x/fun-emoji/png?seed=${author['id']}'),
                    createdAt: createdAt,
                    id: doc.id,
                    text: text,
                  );
                  _addMessage(textMessage);
                }
              }
            });
          } else {
            // Chat room does not exist, create it before initializing the chat

            // Create the chat room document
            await chatsCollection.doc(widget.chat_id).set({
              'chat_id': widget.chat_id,
              'item_id': widget.item_id,
              'buyer_id': widget.chat_id.split('_')[1],
              'seller_id': widget.chat_id.split('_')[1] != widget.current_id
                  ? widget.current_id
                  : widget.other_id,
              // Add any other relevant properties for the chat room
            }).then((_) {
              // Chat room created, proceed with fetching messages and setting up listeners
              // (similar to the code for an existing chat room)
              // ...
            }).catchError((error) {
              // Error occurred while creating the chat room
              print('Error creating chat room: $error');
            });
          }
        })
        .then((value) => {
              // Listen for new messages in the chat room
              messagesCollection
                  .where('chat_id', isEqualTo: widget.chat_id)
                  .orderBy('createdAt')
                  .limitToLast(1)
                  .snapshots()
                  .listen((QuerySnapshot snapshot) {
                List<QueryDocumentSnapshot> documents = snapshot.docs;
                // Process new messages and update your UI
                // e.g., append new messages to a message list or chat bubble widget
                for (var doc in documents) {
                  print("listen: ");
                  print(doc);
                  Map<String, dynamic> author = doc['author'];
                  String text = doc['text'];
                  int createdAt = doc['createdAt'];
                  String type = doc['type'];

                  if (type == 'system') {
                    final systemMessage = types.SystemMessage(
                      createdAt: createdAt,
                      id: doc.id,
                      text: text,
                    );
                    _addMessage(systemMessage);
                    isOfferIntiated = true;

                    if (text.contains("Congratulations!")) {
                      _navigateToSuccessPage();
                    }
                  } else {
                    final textMessage = types.TextMessage(
                      author: types.User(
                          id: author['id'],
                          imageUrl:
                              'https://api.dicebear.com/6.x/fun-emoji/png?seed=${author['id']}'),
                      createdAt: createdAt,
                      id: doc.id,
                      text: text,
                    );
                    _addMessage(textMessage);
                  }
                }
              })
            })
        .catchError((error) {
          // Error occurred while checking if the chat room exists
          print('Error checking chat room existence: $error');
        });
  }

  @override
  void initState() {
    initChat();
    super.initState();
  }

  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToSuccessPage() async {
    Item item = await ItemService().getItemById(widget.item_id);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SuccessPage(
              item: item,
              isOwner: widget.chat_id.split('_')[1] != widget.current_id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('items')
              .doc(widget.item_id)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while fetching the data
              return AppBar(
                title: const Text('Loading...'),
              );
            } else if (snapshot.hasError || !snapshot.hasData) {
              // Handle any errors that occurred during fetching
              return AppBar(
                title: const Text('Error'),
              );
            } else {
              // Data fetched successfully, update the AppBar title with the item name
              String itemName = snapshot.data!.get('title') as String;
              String url = snapshot.data!.get('images')[0] as String;
              String owner = snapshot.data!.get('owner') as String;
              return AppBar(
                title: Text(itemName),
                actions: [
                  if (widget.current_id != owner)
                    InkWell(
                      onTap: () {
                        _handleSystemMessage(
                            'Offer Initiated for $itemName, the owner can choose to accept it by clicking the "Accept Offer" button above');
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Center(
                          child: Text(
                            "Initiate Offer",
                            style: TextStyle(
                              decoration:
                                  TextDecoration.underline, // Add underline
                              fontSize: 18.0, // Increase font size
                              color: Colors.white,
                            ), // Set the text color
                          ),
                        ),
                      ),
                    ),
                  if (widget.current_id == owner && isOfferIntiated)
                    InkWell(
                      onTap: () async {
                        // Send transaction to accept
                        try {
                          await TransactionService().createTransaction(owner,
                              widget.chat_id.split('_')[1], widget.item_id);
                          _handleSystemMessage(
                              'Congratulations! The offer Initiated for $itemName, has been accepted and the credits have been transferred.');
                        } catch (e) {
                          // Handle the error
                          print('Transaction failed: $e');
                          _showErrorPopup(e.toString());
                          return;
                        }
                        _navigateToSuccessPage();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Center(
                          child: Text(
                            "Accept Offer",
                            style: TextStyle(
                              decoration:
                                  TextDecoration.underline, // Add underline
                              fontSize: 18.0, // Increase font size
                              color: Colors.white,
                            ), // Set the text color
                          ),
                        ),
                      ),
                    ),
                  if (url != null)
                    CircleAvatar(
                      backgroundImage: NetworkImage(url),
                    )
                ],
              );
            }
          },
        ),
      ),
      body: Chat(
        showUserAvatars: true,
        messages: _messages,
        // onAttachmentPressed: _handleImageSelection,
        // onMessageTap: _handleMessageTap,
        onPreviewDataFetched: _handlePreviewDataFetched,
        onSendPressed: _handleSendPressed,
        user: types.User(id: widget.current_id),
        theme: const DefaultChatTheme(
          inputBackgroundColor: Colors.grey,
          primaryColor: Colors.green,
        ),
      ),
    );
  }

  void _addMessage(types.Message message) {
    // avoid adding duplicated messages
    final index = _messages.indexWhere((element) => element.id == message.id);
    if (index == -1) {
      setState(() {
        _messages.insert(0, message);
      });
    }
  }

  // void _handleAttachmentPressed() {
  //   showModalBottomSheet<void>(
  //     context: context,
  //     builder: (BuildContext context) => SafeArea(
  //       child: SizedBox(
  //         height: 144,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: <Widget>[
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 _handleImageSelection();
  //               },
  //               child: const Align(
  //                 alignment: AlignmentDirectional.centerStart,
  //                 child: Text('Photo'),
  //               ),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 _handleFileSelection();
  //               },
  //               child: const Align(
  //                 alignment: AlignmentDirectional.centerStart,
  //                 child: Text('File'),
  //               ),
  //             ),
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Align(
  //                 alignment: AlignmentDirectional.centerStart,
  //                 child: Text('Cancel'),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _handleFileSelection() async {
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.any,
    // );

    // if (result != null && result.files.single.path != null) {
    //   final message = types.FileMessage(
    //     author: _user,
    //     createdAt: DateTime.now().millisecondsSinceEpoch,
    //     id: randomString(),
    //     name: result.files.single.name,
    //     size: result.files.single.size,
    //     uri: result.files.single.path!,
    //   );

    //   _addMessage(message);
    // }
  }

  // void _handleImageSelection() async {
  //   final result = await ImagePicker().pickImage(
  //     imageQuality: 70,
  //     maxWidth: 1440,
  //     source: ImageSource.gallery,
  //   );

  //   if (result != null) {
  //     final bytes = await result.readAsBytes();
  //     final image = await decodeImageFromList(bytes);

  //     final message = types.ImageMessage(
  //       author: types.User(id: widget.current_id),
  //       createdAt: DateTime.now().millisecondsSinceEpoch,
  //       height: image.height.toDouble(),
  //       id: randomString(),
  //       name: result.name,
  //       size: bytes.length,
  //       uri: result.path,
  //       width: image.width.toDouble(),
  //     );

  //     _addMessage(message);
  //   }
  // }

  // void _handleMessageTap(BuildContext _, types.Message message) async {
  //   if (message is types.FileMessage) {
  //     var localPath = message.uri;

  //     if (message.uri.startsWith('http')) {
  //       try {
  //         final index =
  //             _messages.indexWhere((element) => element.id == message.id);
  //         final updatedMessage =
  //             (_messages[index] as types.FileMessage).copyWith(
  //           isLoading: true,
  //         );

  //         setState(() {
  //           _messages[index] = updatedMessage;
  //         });

  //         final client = http.Client();
  //         final request = await client.get(Uri.parse(message.uri));
  //         final bytes = request.bodyBytes;
  //         final documentsDir = (await getApplicationDocumentsDirectory()).path;
  //         localPath = '$documentsDir/${message.name}';

  //         if (!File(localPath).existsSync()) {
  //           final file = File(localPath);
  //           await file.writeAsBytes(bytes);
  //         }
  //       } finally {
  //         final index =
  //             _messages.indexWhere((element) => element.id == message.id);
  //         final updatedMessage =
  //             (_messages[index] as types.FileMessage).copyWith(
  //           isLoading: null,
  //         );

  //         setState(() {
  //           _messages[index] = updatedMessage;
  //         });
  //       }
  //     }

  //     // await OpenFilex.open(localPath);
  //   }
  // }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSystemMessage(String message) {
    const uuid = Uuid();
    final timeNow = DateTime.now().millisecondsSinceEpoch;

    final types.SystemMessage systemMessage = types.SystemMessage(
      createdAt: timeNow,
      id: uuid.v4(), // Generate a unique identifier using UUID
      text: message,
    );

    // Save the text message to the Firestore collection
    FirebaseFirestore.instance
        .collection('messages')
        .doc(systemMessage.id)
        .set({
      ...systemMessage.toJson(),
      'chat_id': widget.chat_id,
    }).then((_) {
      FirebaseFirestore.instance
          .collection('item_chats')
          .doc(widget.chat_id)
          .update({
        'last_updated': timeNow,
        'last_message': message,
      });
    }).catchError((error) {
      // Error occurred while sending the message
      print('Error sending message: $error');
    });
  }

  void _handleSendPressed(types.PartialText message) {
    const uuid = Uuid();
    final timeNow = DateTime.now().millisecondsSinceEpoch;

    final types.TextMessage textMessage = types.TextMessage(
      author: types.User(id: widget.current_id),
      createdAt: timeNow,
      id: uuid.v4(), // Generate a unique identifier using UUID
      text: message.text,
    );

    // Save the text message to the Firestore collection
    FirebaseFirestore.instance.collection('messages').doc(textMessage.id).set({
      ...textMessage.toJson(),
      'chat_id': widget.chat_id,
    }).then((_) {
      FirebaseFirestore.instance
          .collection('item_chats')
          .doc(widget.chat_id)
          .update({
        'last_updated': timeNow,
        'last_message': message.text,
      });
    }).catchError((error) {
      // Error occurred while sending the message
      print('Error sending message: $error');
    });

    // _addMessage(textMessage);
  }
}
