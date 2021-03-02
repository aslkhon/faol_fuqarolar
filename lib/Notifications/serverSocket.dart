import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

class SocketService {
  IO.Socket socket;

  createSocketConnection() async {
    socket = IO.io(
      'https://server.faol-fuqarolar.uz/',
      <String, dynamic>{
        'transports': ['websocket']
      });
    final token = await signIn();
    socket.on('connect', (_) => {});
    socket.emit('authentication', {'token': token});
    socket.on('authenticated', (_) => print('If this prints, then you are successfully authenticated'));
    socket.on('disconnected', (_) => print('Disconnected'));
  }

  Future<String> signIn() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final phoneNumber = preferences.getString('phone');
    const url = 'https://server.faol-fuqarolar.uz/api/auth/loginphone';
    try {
      final response = await http.post(
        url,
        body: {'phone': phoneNumber}
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['token'];
      }
      return null;
    } catch (error) {
      throw error;
    }
  }
}