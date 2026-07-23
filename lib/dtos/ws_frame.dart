class WsFrame {
  final String type;
  final Map<String, dynamic> data;
  final int timestamp;

  WsFrame({ required this.type, required this.data, required this.timestamp });

  factory WsFrame.fromJson(Map<String, dynamic> json) {
    return WsFrame(
      type: json['type'],
      data: json['data'],
      timestamp: json['timestamp'],
    );
  }
}