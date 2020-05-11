import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socketchat/core/config/config.dart';
import 'package:socketchat/core/viewmodels/chat_provider.dart';

class JoinScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Config.instance.primaryColor,
        title: Text("Socket Chats"),
      ),
      body: JoinBody(),
    );
  }
}

class JoinBody extends StatefulWidget {
  @override
  _JoinBodyState createState() => _JoinBodyState();
}

class _JoinBodyState extends State<JoinBody> {
  GlobalKey<FormState> _formKey;
  String _username;
 
  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();

    final chatProv = Provider.of<ChatProvider>(context, listen: false);
    chatProv.setRoomContext(context);
    print("Initt");
    chatProv.initSocket();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState.save();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Consumer<ChatProvider>(
              builder: (context, chatProv, _) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    chatProv.validation,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ), 
                  ),
                );
              },
            ),
            _usernameTextField(),
            SizedBox(height: 20),
            _joinButton()
          ],
        ),
      ),
    );
  }

  Widget _joinButton() {
    return Consumer<ChatProvider>(
      builder: (context, chatProv, _) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 45,
          child: RaisedButton(
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                await chatProv.setUsername(_username);
                chatProv.sendCheckUser();
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            ),
            color: Config.instance.primaryColor,
            child: Text(
              "Join Room",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white
              )
            ),
          ),
        );
      },
    );
  }

  Widget _usernameTextField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(color: Colors.black87),
      validator: (_input) {
        return _input.length > 3 && !_input.contains(" ") ? null : "Please enter valid username";
      },
      onSaved: (_input) {
        setState(() {
          _username = _input;
        });
      },
      cursorColor: Colors.white,
      textInputAction: TextInputAction.go,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: "Username",
        hintStyle: TextStyle(color: Colors.black87),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white )
        )
      ),
    );
  }
}