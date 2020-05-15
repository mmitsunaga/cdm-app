import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {

  final Map<String, dynamic> data;

  ChatMessage(this.data);

  @override
  Widget build(BuildContext context){

    final temImage = data['urlImage'] != null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar (
              backgroundImage: NetworkImage(this.data['senderPhotoUrl'])
            )
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                temImage ? Image.network(data['urlImage'], width: 250) : Text(data['text'], style: TextStyle(fontSize: 16)),
                Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Text('Enviado por ${data['senderName']}',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey
                      )
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
