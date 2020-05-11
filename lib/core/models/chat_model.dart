
class ChatModel {
  String id;
  String name;
  String message;
  String time;
  bool isMe;

  ChatModel({
    this.id, this.name, 
    this.message, this.isMe, 
    this.time
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json["id"],
      message: json["message"],
      time: json["time"],
      isMe: json["isme"],
      name: json["name"]
    );
  }
}