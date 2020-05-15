
import 'dart:io';
import 'package:chatter/widget/chat_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chatter/widget/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();

  final GlobalKey<ScaffoldState> _scaffoldKStateKey = GlobalKey<ScaffoldState>();

  FirebaseUser _currentUser;

  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen((newUser){
      setState(() {
        _currentUser = newUser;
      });
    });
  }

  Future<FirebaseUser> _getUser() async {
    try {
      if (_currentUser == null){

        final GoogleSignInAccount googleAccount =
        await googleSignIn.signIn();

        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.getCredential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken
        );

        final AuthResult authResult = await FirebaseAuth.instance.signInWithCredential(credential);

        return authResult.user;

      } else {
        return _currentUser;
      }
    } catch (error){
      return null;
    }
  }

  void showSnackBar(String message){
    _scaffoldKStateKey.currentState.showSnackBar(
        SnackBar(content: Text(message)));
  }

  void _sendMessage({String text, File img}) async {

    final FirebaseUser user = await _getUser();

    if (user == null){
      _scaffoldKStateKey.currentState.showSnackBar(
          SnackBar(
            content: Text('Não foi possível logar. Tente Novamente.'),
            backgroundColor: Colors.red,
          )
      );
    }

    Map<String, dynamic> data = {
      'uid': user.uid,
      'senderName': user.displayName,
      'senderPhotoUrl': user.photoUrl,
      'time': Timestamp.now()
    };

    setState(() { _isLoadingImage = (img != null); });

    if (img != null){
      String filename = DateTime.now().millisecondsSinceEpoch.toString();
      StorageUploadTask task = FirebaseStorage.instance.ref().child(user.uid).child(filename).putFile(img);
      StorageTaskSnapshot snapshot = await task.onComplete;
      String url = await snapshot.ref.getDownloadURL();
      data['urlImage'] = url;
      setState(() { _isLoadingImage = (data['url'] != null); });
    }

    if (text != null)  data['text'] = text;

    Firestore.instance.collection('messages').add(data);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKStateKey,
      appBar: AppBar(
        title: _currentUser != null ? Text('Olá ${_currentUser.displayName}') : Text('Chat Online'),
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          _currentUser == null ? Container() :
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: (){
              FirebaseAuth.instance.signOut();
              googleSignIn.signOut();
              showSnackBar('Você saiu com sucesso!!');
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('messages').orderBy('time').snapshots(),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    List<DocumentSnapshot> documents = snapshot.data.documents.reversed.toList();
                    return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index){
                        return ChatMessage(documents[index].data);
                      }
                    );
                }
              },
            ),
          ),
          _isLoadingImage ? CircularProgressIndicator() : Container(),
          TextComposer(_sendMessage)
        ],
),
);
}
}
