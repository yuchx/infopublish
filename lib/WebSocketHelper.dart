// import 'package:flutter/cupertino.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
//
// class WebSocketHelper {
//   IOWebSocketChannel createWebSocket(String url) {
//     print("createWebSocket url:$url");
// //    return new IOWebSocketChannel.connect('$url');//ws://echo.websocket.org
//
//     try {
//       if(url.isNotEmpty) {
//         print("createWebSocket url:$url");
//         return new IOWebSocketChannel.connect('$url');
//       }
//
//       return null;
//     } on WebSocketChannelException {
//       print("createWebSocket Exception");
//       return null;
//     }
//   }
//
//   void sendMessage(WebSocketChannel channel, String text) {
//     if(channel != null) {
//       channel.sink.add(text);
// //      print("sendMessage：$text");
//     }
//   }
//
//   StreamBuilder receiveMessage(WebSocketChannel channel) {
//     if(channel != null) {
//       print('receiveMessage：1');
//       return new StreamBuilder(
//         stream: channel.stream,
//         builder: (context, snapshot) {
//           var text = snapshot.hasData ? '${snapshot.data}' : '';
//           print('receiveMessage：$text');
//           //return new Text(text);
//           return new Padding(
//             padding: const EdgeInsets.symmetric(vertical: 24.0),
//             child: new Text(snapshot.hasData ? '${snapshot.data}' : ''),
//           );
//         },
//       );
//     }
//
//     return null;
//   }
//
//   void listen(WebSocketChannel channel) {
//     // 监听消息
//     channel.stream.listen((message) {
//       print('listen：$message');
//
//     });
//   }
//
//   void dispose(WebSocketChannel channel) {
//     if(channel != null) {
//       print("WebSocket close");
//       channel.sink.close();
//     }
//   }
// }
