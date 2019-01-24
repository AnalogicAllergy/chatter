import 'package:cloud_firestore/cloud_firestore.dart';
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
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
