import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socketchat/core/config/config.dart';
import 'package:socketchat/core/models/chat_model.dart';
import 'package:socketchat/core/viewmodels/chat_provider.dart';
import 'package:socketchat/ui/widgets/input_chat.dart';


class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Config.instance.primaryColor,
        leading: Consumer<ChatProvider>(
          builder: (context, chatProv, _) {
            return IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => chatProv.leaveRoom(),
            );
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Chat Room"),
            Consumer<ChatProvider>(
              builder: (context, chatProv, _) {
                return Text(
                  chatProv.statusGroup,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white
                  ),
                );
              },
            )
          ],
        ),
      ),
      body: ChatBody(),
    );
  }
}


class ChatBody extends StatefulWidget {

  @override
  _ChatBodyState createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  var chatController = TextEditingController();

  void submitMessage(String message) {
    Provider.of<ChatProvider>(context, listen: false).submitMessage(message);
    chatController.text = "";
  }

  @override
  void initState() {
    super.initState();

    final chatProv = Provider.of<ChatProvider>(context, listen: false);
    chatProv.setChatContext(context);
  }
  @override
  Widget build(BuildContext context) {

    return Container(
      width: Config.instance.deviceWidth(context),
      height: Config.instance.deviceHeight(context),
      child: Stack(
        children: <Widget>[
          //For chat field
          _chatField(),
          //for input field
          _inputField(),
        ],
      ),
    );
  }

  Widget _chatItem(ChatModel chats) {
    return Align(
      alignment: chats.isMe ? Alignment.bottomRight : Alignment.bottomLeft,
      child: Column(
        children: <Widget>[
          chats.name.isEmpty 
          ? Center(
            child: Text(
              chats.message,
              style: TextStyle(
                color: Colors.black45,
                fontSize: 13
              ),
            ),
          )
          : Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: chats.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: <Widget>[

              Flexible(
                child: Container(
                  margin: EdgeInsets.only(top: 10, left: chats.isMe ? 50 : 0, right: chats.isMe ? 0 : 50),
                  // width: Config.instance.deviceWidth(context),
                  decoration: BoxDecoration(
                    color: chats.isMe ? Config.instance.primaryColor : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(chats.isMe ? 15 : 0),
                      bottomRight: Radius.circular(chats.isMe ? 0 : 15)
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        chats.isMe == false ? Text(
                          chats.name,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Config.instance.primaryColor
                          ),
                        ) : SizedBox(),
                        chats.isMe == false ? SizedBox(height: 5) : SizedBox(),
                        Text(
                          chats.message,
                          textAlign: chats.isMe ? TextAlign.right : TextAlign.left,
                          style: TextStyle(
                            color: chats.isMe ? Colors.white : Colors.black87
                          ),
                        ),
                      ],
                    ),
                  )
                ),
              ),
            ],
          ),

          //For times
          chats.name.isNotEmpty ? Consumer<ChatProvider>(
            builder: (context, chatsProv, _) {
              return Align(
                alignment: chats.isMe ? Alignment.bottomRight : Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    chats.time,
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 13
                    ),
                  ),
                ),
              );
            },
          ) : SizedBox()
        ],
      ),
    );
  }

  Widget _chatField() {
    return Consumer<ChatProvider>(
      builder: (context, chatsProv, _) {

        return Container(
          height: Config.instance.deviceHeight(context),
          margin: EdgeInsets.only(bottom: 83),
          padding: EdgeInsets.only(left: 10, right: 10),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: chatsProv.chatList.length,
            reverse: true,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return _chatItem(chatsProv.chatList[index]);
            },
          ),
        );
      },
    );
  }

  Widget _inputField() {
    return Consumer<ChatProvider>(
      builder: (context, chatsProv, _) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.white.withOpacity(0.1),
            padding: EdgeInsets.all(13),
            child: InputChat(
              controller: chatController,
              action: TextInputAction.done,
              type: TextInputType.text,
              hintText: "Ketik pesanmu",
              onChange: () => chatsProv.sendTyping(),
              onClickSend: () {
                chatsProv.submitMessage(chatController.text);
                chatController.text = "";
              },

            ),
          ),
        );
      },
    );
  }
}