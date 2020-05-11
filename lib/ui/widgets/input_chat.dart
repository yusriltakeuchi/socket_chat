import 'package:flutter/material.dart';
import 'package:socketchat/core/config/config.dart';

class InputChat extends StatelessWidget {
  TextEditingController controller;
  TextInputAction action;
  TextInputType type;
  String hintText;
  bool readOnly;
  Function onClickSend;
  Function onChange;

  InputChat({
    @required this.controller, @required this.action,
    @required this.type, this.hintText,
    @required this.onClickSend, this.readOnly = false,
    @required this.onChange
  });
  
  @override
  Widget build(BuildContext context) {
    
    return Row(
      children: <Widget>[
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  offset: Offset(2, 5),
                  blurRadius: 10,
                  spreadRadius: 1
                )
              ]
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5, top: 5),
              child: TextField(
                controller: controller,
                textInputAction: action,
                keyboardType: type,
                readOnly: readOnly,
                onChanged: (String text) => onChange(),
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(fontSize: 16),
                  border: InputBorder.none,
                ),
              ),
            )
          ),
        ),
        SizedBox(width: 10),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(70),
            boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  offset: Offset(2, 5),
                  blurRadius: 10,
                  spreadRadius: 1
                )
              ]
          ),
          child: Material(
            color: Config.instance.primaryColor,
            borderRadius: BorderRadius.circular(70),
            child: InkWell(
              onTap: onClickSend,
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(70),
              ),
              child: Center(
                child: Icon(Icons.send, color: Colors.white)
              ),
            ),
          ),
        )
      ],
    );
  }
}