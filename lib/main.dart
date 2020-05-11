import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:adhara_socket_io/manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socketchat/core/config/config.dart';
import 'package:socketchat/core/viewmodels/chat_provider.dart';
import 'package:socketchat/ui/views/join_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ChatProvider(),
        )
      ],
      child: MaterialApp(
        title: 'Chatroom',
        theme: ThemeData(
          primaryColor: Config.instance.primaryColor,
          accentColor: Config.instance.primaryColor
        ),
        debugShowCheckedModeBanner: false,
        home: JoinScreen(),
      ),
    );
  }
}

