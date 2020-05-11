
import 'package:flutter/material.dart';

class Config {
  static Config instance = Config();

  //* Color config
  Color primaryColor = Color(0xffff4757);

  //* Sockets connections
  String hostSocket = "http://192.168.200.16:8004";
  String identifier = "default";


  //* Device orientations config
  double deviceHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double deviceWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
}