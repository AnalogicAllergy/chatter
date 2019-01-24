import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
              child: ListView(
                children: <Widget>[
                  ChatMessage(),
                  ChatMessage(),
                  ChatMessage(),
                ],
              ),
            ),
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
  bool isComposing = false;
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
                onPressed: () {
                  //camera upload
                },
              ),
            ),
            Expanded(
              child: TextField(
                decoration:
                    InputDecoration.collapsed(hintText: "Enviar uma mensagem"),
                onChanged: (text) {
                  isComposing = text.length > 0;
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoButton(
                      child: Text("Enviar"),
                      onPressed: isComposing ? () {} : null,
                    )
                  : IconButton(
                      icon: Icon(Icons.send),
                      onPressed: isComposing ? () {} : null,
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://s.yimg.com/ny/api/res/1.2/QFwOZRlxOZXlD1gKCmEPlA--~A/YXBwaWQ9aGlnaGxhbmRlcjtzbT0xO3c9ODAw/http://media.zenfs.com/en-US/homerun/ccn_656/15286c5fe8cd5c20e3a7ea1fbae1642a'),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Daniel", style: Theme.of(context).textTheme.subhead),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Text("Teste"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
