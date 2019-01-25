import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  //Gravando
  Firestore.instance
      .collection("mensagens")
      .document("msg2")
      .setData({"from": "Joao", "texto": "Ola tudo bem Daniel?"});

  //Lendo
  DocumentSnapshot snap =
      await Firestore.instance.collection("mensagens").document("msg1").get();
  //debugPrint(snap.data.toString());
  //Lendo todos os documents
  QuerySnapshot querySnapshot =
      await Firestore.instance.collection("mensagens").getDocuments();
  querySnapshot.documents.forEach((f) => print(f.documentID));

  //Lendo e listening
  Firestore.instance.collection("mensagens").snapshots().listen((snapshot) {
    snapshot.documents.forEach((f) => print(f.data));
  });
  runApp(HomeApp());
}

final ThemeData kIOSTheme = ThemeData(
    primarySwatch: Colors.orange,
    primaryColor: Colors.grey[100],
    primaryColorBrightness: Brightness.light);

final ThemeData kDefault = ThemeData(
    primarySwatch: Colors.purple, accentColor: Colors.orangeAccent[400]);

final googleSignIn = GoogleSignIn();
final auth = FirebaseAuth.instance;

Future<Null> _ensureLoggedIn() async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) {
    user = await googleSignIn.signInSilently();
  }
  if (user == null) {
    user = await googleSignIn.signIn();
  }
  if (await auth.currentUser() == null) {
    GoogleSignInAuthentication credentials =
        await googleSignIn.currentUser.authentication;
    await auth.signInWithGoogle(
        idToken: credentials.idToken, accessToken: credentials.accessToken);
  }
}

_handleSubmitted(String text) async {
  await _ensureLoggedIn();
  _sendMessage(text: text);
}

void _sendMessage({String text, String imgUrl}) {
  Firestore.instance.collection("messages").add({
    "text": text,
    "imgUrl": imgUrl,
    "senderName": googleSignIn.currentUser.displayName,
    "senderPhotoUrl": googleSignIn.currentUser.photoUrl
  });
}

class HomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chat App",
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context).platform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefault,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chat App"),
          centerTitle: true,
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0 : 4,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: StreamBuilder(
                    stream:
                        Firestore.instance.collection("messages").snapshots(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        default:
                          return ListView.builder(
                            itemBuilder: (context, index) {
                              List r =
                                  snapshot.data.documents.reversed.toList();
                              return ChatMessage(r[index].data);
                            },
                            reverse: true,
                            itemCount: snapshot.data.documents.length,
                          );
                      }
                    })),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: TextComposer(),
            )
          ],
        ),
      ),
    );
  }
}

class TextComposer extends StatefulWidget {
  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final _textEditingController = TextEditingController();
  bool isComposing = false;

  void _reset() {
    _textEditingController.clear();
    setState(() {
      isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: Theme.of(context).platform == TargetPlatform.iOS
            ? BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200])))
            : null,
        child: Row(
          children: <Widget>[
            Container(
              child: IconButton(
                icon: Icon(Icons.photo_camera),
                onPressed: () async {
                  //camera upload
                  await _ensureLoggedIn();
                  File imgFile =
                      await ImagePicker.pickImage(source: ImageSource.camera);
                  if (imgFile == null) return;
                  StorageUploadTask task = FirebaseStorage.instance
                      .ref()
                      .child(googleSignIn.currentUser.id.toString() +
                          DateTime.now().millisecondsSinceEpoch.toString())
                      .putFile(imgFile);
                  _sendMessage(
                      imgUrl: (await task.future).downloadUrl.toString());
                },
              ),
            ),
            Expanded(
              child: TextField(
                controller: _textEditingController,
                decoration:
                    InputDecoration.collapsed(hintText: "Enviar uma mensagem"),
                onChanged: (text) {
                  setState(() {
                    isComposing = text.length > 0;
                  });
                },
                onSubmitted: (text) {
                  _handleSubmitted(text);
                  _reset();
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoButton(
                      child: Text("Enviar"),
                      onPressed: isComposing
                          ? () {
                              _handleSubmitted(_textEditingController.text);
                              _reset();
                            }
                          : null,
                    )
                  : IconButton(
                      icon: Icon(Icons.send),
                      onPressed: isComposing
                          ? () {
                              _handleSubmitted(_textEditingController.text);
                              _reset();
                            }
                          : null,
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final Map<String, dynamic> data;
  ChatMessage(this.data);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage(data["senderPhotoUrl"]),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(data["senderName"],
                    style: Theme.of(context).textTheme.subhead),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: data["imgUrl"] != null
                      ? Image.network(
                          data["imgUrl"],
                          width: 250,
                        )
                      : Text(data["text"]),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
