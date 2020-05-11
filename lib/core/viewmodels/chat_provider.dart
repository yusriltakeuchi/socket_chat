import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:adhara_socket_io/manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:socketchat/core/config/config.dart';
import 'package:socketchat/core/models/chat_model.dart';
import 'package:socketchat/ui/views/chat_screen.dart';
import 'package:socketchat/ui/views/join_screen.dart';

class ChatProvider extends ChangeNotifier {

  //* ---------------------
  //*  PROPERTY FIELDS
  //* ---------------------

  //* Variable to save all conversations
  List<ChatModel> _chatList;
  List<ChatModel> get chatList => _chatList;

  //* Context for join screen
  BuildContext _joinRoomContext;
  BuildContext get joinRoomContext => _joinRoomContext;

  //* Context for chat screen
  BuildContext _chatRoomContext;
  BuildContext get chatRoomContext => _chatRoomContext;

  //* Variable to save the username and expose to another user
  String _username;
  String get username => _username;

  //* This is for validations in join room screen
  String _validation = "Please enter your username";
  String get validation => _validation;

  //* Manager for socketio
  SocketIOManager _manager;
  SocketIOManager get manager => _manager;

  //* Socket
  SocketIO _socket;
  SocketIO get socket => _socket;

  Map<String, SocketIO> _sockets = {};
  Map<String, SocketIO> get sockets => _sockets;
  
  Map<String, bool> _isProbablyConnected = {};
  Map<String, bool> get isProbablyConnected => _isProbablyConnected;

  //* Variable to save total users online
  int _userOnline = 0;
  int get userOnline => _userOnline;

  //* Variable to show status group in Appbar
  String _statusGroup;
  String get statusGroup => _statusGroup;

  final format = new DateFormat('hh:mm');

  //* ---------------------
  //*  INITIALIZE FUNCTION
  //* ---------------------

  /*
  * When you're in join room screen,
  * you must call this in the initState
  */
  void setRoomContext(BuildContext context) async {
    _joinRoomContext = await context;
    notifyListeners();
  }

  /*
  * When you're in chat room screen,
  * you must call this in the initState
  */
  void setChatContext(BuildContext context) async {
    _chatRoomContext = await context;
    notifyListeners();
  }

  /*
  * Function to save username after
  * successfully joining room
  */
  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  /*
  * Function to set statusGroup in Appbar
  */
  void setStatusGroup(String text) {
    _statusGroup = text;
    notifyListeners();
  }

  /*
  * Function to initializing Socket 
  * and another required variable
  */
  void initSocket() async {
    _manager = SocketIOManager();
    _chatList = new List<ChatModel>();
    _isProbablyConnected[Config.instance.identifier] = true;
    _socket = await _manager.createInstance(SocketOptions(
        Config.instance.hostSocket,
        nameSpace: "/",
        enableLogging: false,
        transports: [Transports.WEB_SOCKET/*, Transports.POLLING*/] //Enable required transport
    ));
    notifyListeners();

    handleEvent();
  }


  //* ---------------------
  //*  EVENT FUNCTIONS
  //* ---------------------

  /*
  * Function to send message 
  * to socket server
  */
  void submitMessage(String message) {
    if (message.isNotEmpty) {
      _sockets[Config.instance.identifier].emit("message", ["${username}|${message}"]);
      _chatList.add(ChatModel.fromJson({
        "id": (chatList.length + 1).toString(),
        "message": message,
        "time": format.format(DateTime.now()),
        "isme": true,
        "name": username,
      }));

      _chatList.sort((a, b) => int.parse(b.id).compareTo(int.parse(a.id)));
      
      notifyListeners();
    }
  }

  /*
  * Function to send check username
  * event to check if the username already exists
  */
  void sendCheckUser() {
    _sockets[Config.instance.identifier].emit("checkuser", [_username]);
    notifyListeners();
  }
  
  /*
  * Function to send leaving event
  * to server and set required
  * variable to null
  */
  void leaveRoom() {
    _sockets[Config.instance.identifier].emit("leaving", [_username]);
    _chatList.clear();
    _validation = "Please enter your username";
    _username = "";

    notifyListeners();
    Navigator.pop(chatRoomContext);
  }

  /*
  * Function to send trigger event "typing"
  * to server, and server will broadcast to all listener
  */
  void sendTyping() {
    _sockets[Config.instance.identifier].emit("typing", ["${username} sedang mengetik"]);
    notifyListeners();
  }


  //* ---------------------
  //* HANDLE EVENT FIELD
  //* ---------------------

  /*
  * Function to handle all event from server
  */
  void handleEvent() async {
    socket.onDisconnect(_handleDisconnect());
    socket.on("message", (data) => _handleMessage(data));
    socket.on("join", (data) => _handleNewUserJoin(data));
    socket.on("leaving", (data) => _handleUserLeaving(data));
    socket.on("checkuser", (data) => _handleCheckUser(data));
    socket.on("typing", (data) => _handleTyping(data));
    socket.connect();
    sockets[Config.instance.identifier] = socket;
  }

  /*
  * This function handle "checkuser" event
  * from server 
  */
  void _handleCheckUser(data) {
    if (data == "available") {
      //* send event join with username
      _sockets[Config.instance.identifier].emit("join", [_username]);
      _validation = "Join room successfully";

      _chatList.clear();
      
      Navigator.push(joinRoomContext, MaterialPageRoute(
        builder: (joinRoomContext) => ChatScreen()
      ));
      notifyListeners();

    } else {
      _validation = "Username already exists";
    }
    notifyListeners();
  }

  /*
  * Function to handle event "leaving"
  * from server, and show the information
  * to the chatlist
  */
  void _handleUserLeaving(data) {
    var msg = data.toString().split("|");
    _chatList.add(ChatModel.fromJson({
      "id": (chatList.length + 1).toString(),
      "message": msg[0],
      "time": format.format(DateTime.now()),
      "isme": false,
      "name": "",
    }));
    //* Use this to sorting from new chat
    _chatList.sort((a, b) => int.parse(b.id).compareTo(int.parse(a.id)));

    //* Set total users online and show to statusGroup
    _userOnline = int.parse(msg[1]);
    setStatusGroup("${_userOnline} Users Online");

    notifyListeners();
  }

  /*
  * Function to handle event "join"
  * from server when someone join to the
  * chatroom
  */
  void _handleNewUserJoin(data) {
    var msg = data.toString().split("|");
    _chatList.add(ChatModel.fromJson({
      "id": (chatList.length + 1).toString(),
      "message": msg[0],
      "time": format.format(DateTime.now()),
      "isme": false,
      "name": "",
    }));
    _chatList.sort((a, b) => int.parse(b.id).compareTo(int.parse(a.id)));
    _userOnline = int.parse(msg[1]);
    setStatusGroup("${_userOnline} Users Online");

    notifyListeners();
  }

  /*
  * Function to handle event "message"
  * from server and show the message to the 
  * chatlist
  */
  void _handleMessage(data) {
    var msg = data.split("|");
    if (msg[0] != username) {
      _chatList.add(ChatModel.fromJson({
        "id": (chatList.length + 1).toString(),
        "message": msg[1],
        "time": format.format(DateTime.now()),
        "isme": false,
        "name": msg[0],
      }));
      _chatList.sort((a, b) => int.parse(b.id).compareTo(int.parse(a.id)));
    }

    notifyListeners();
  }

  /*
  * Function to handle event "typing"
  * from server. This function will triggered
  * when someone type a message
  */
  void _handleTyping(data) async {
    var msg = data.toString().split(" ");
    //* msg[0] = username
    //* valiate only get another user typing event
    if (msg[0] != username) {
      setStatusGroup(data.toString());
      await Future.delayed(Duration(seconds: 5)).then((val) {
        setStatusGroup("${_userOnline} Users Online");
      });
    }
  }

  /*
  * Function to handle when user disconnect
  */
  _handleDisconnect() {
    //Handling disconnect
    print("User disconnect");
  }

}