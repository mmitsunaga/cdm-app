import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {

  final Function({String text, File img}) sendMessage;

  TextComposer(this.sendMessage);

  @override
  _TextComposerState createState() => _TextComposerState();

}

class _TextComposerState extends State<TextComposer> {

  bool _isComposing = false;

  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _reset(){
    controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed:() async {
              File imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
              if (imageFile == null) return;
              widget.sendMessage(img: imageFile);
            }
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration.collapsed(hintText: 'Escreva uma mensagem'),
              onChanged: (value){
                setState(() {
                  _isComposing = value.isNotEmpty;
                });
              },
              onSubmitted: (value){
                widget.sendMessage(text: value);
                _reset();
              },
            ),
          ),
          IconButton(
              icon: Icon(Icons.send),
              onPressed: _isComposing ? (){
                widget.sendMessage(text: controller.text);
                _reset();
              } : null
          )
        ],
      ),
    );
  }

}
