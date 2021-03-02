import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:mime_type/mime_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  Future<void> signUp(String phoneNumber) async {
    print(phoneNumber);
    const url = 'https://api.faol-fuqarolar.uz/api/citizens/phone';
    try {
      final response = await http.post(
          url,
          body: {'smsSecret': "LC4dsMnJHy7ogGew3d6H", 'phone': phoneNumber}
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode != 200) {
        throw HttpException;
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<int> verifyCode(int code, String phoneNumber) async {
    final _prefs = await SharedPreferences.getInstance();
    const url = 'https://api.faol-fuqarolar.uz/api/citizens/code';
    try {
      final response = await http.post(
          url,
          body: json.encode({'phone': '998$phoneNumber', 'code': code}),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          }
      );
      final responseData = json.decode(response.body);
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        _prefs.setInt('userId', responseData['id']);
        _prefs.setString('name', responseData['name']);
        _prefs.setString('surname', responseData['surname']);
        await _firebaseToken(phoneNumber);
      } else if (response.statusCode != 202 && response.statusCode != 200) {
        throw HttpException;
      }
      return response.statusCode;
    } catch (error) {
      throw error;
    }
  }

  Future<void> _firebaseToken(String phone) async {
    await _fetchData(phone);
    final _prefs = await SharedPreferences.getInstance();
    final _token = _prefs.getString('token');
    print(_token);
    final FirebaseMessaging _fbm = FirebaseMessaging();
    String token = await _fbm.getToken();
    const url = 'https://api.obodpskent.uz/api/tokens';
    try {
      final response = await http.post(
          url,
          body: {'phone': phone, 'token': token},
          headers: {
            'Authorization': 'Bearer $_token'
          }
      );
      print(response.statusCode);
      print(response.body);
    } catch (error) {
      throw error;
    }
  }

  _fetchData(String phoneNumber) async {
    final _prefs = await SharedPreferences.getInstance();
    const url = 'https://api.faol-fuqarolar.uz/api/auth/loginPhone';
    try {
      if (phoneNumber != null) {
        final response = await http.post(
            url,
            body: json.encode({'phone': phoneNumber}),
            headers: {
              'Content-type': 'application/json',
              'Accept': 'application/json'
            }
        );
        final responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          _prefs.setString('token', responseData['token']);
        } else if (response.statusCode != 202 && response.statusCode != 200) {
          throw HttpException;
        }
      }
    } catch (error) {
      throw error;
    }
  }

  Future<int> formUser(String name, String surname, String phoneNumber) async {
    const url = 'https://api.faol-fuqarolar.uz/api/citizens';
    try {
      final response = await http.post(
          url,
          body: json.encode({
            'name': name,
            'surname': surname,
            'street': 'Sharof Rashidov',
            'home': 'Uy',
            'phone': phoneNumber,
            'imageId': 1
          }),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          }
      );
      final responseData = json.decode(response.body);
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        _fetchData(phoneNumber);
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('userId', responseData['id']);
        prefs.setString('phone', responseData['phone']);
        prefs.setString('name', name);
        prefs.setString('surname', surname);
        await _firebaseToken(responseData['phone']);
      } else if (response.statusCode != 202 && response.statusCode != 200) {
        throw HttpException;
      }
      return response.statusCode;
    } catch (error) {
      throw error;
    }
  }

  Future<Response> sentImage(String imagePath) async {
    final _prefs = await SharedPreferences.getInstance();
    final _token = _prefs.getString('token');
    Map<String, String> headers = {'Authorization': 'Bearer $_token'};
    const url = 'https://api.faol-fuqarolar.uz/api/files';
    try {
      String mimeType = mime(imagePath);
      String mimee = mimeType.split('/')[0];
      String type = mimeType.split('/')[1];
      Dio dio = Dio();
      dio.options.headers = headers;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath,
            contentType: MediaType(mimee, type),
            filename: imagePath.split('/').last)
      });

      final response = await dio.post(
          url,
          data: formData,
          options: Options(headers: headers)
      );
      if (response.statusCode != 202 && response.statusCode != 201) {
        final _prefs = await SharedPreferences.getInstance();
        final DateTime now = DateTime.now();
        final DateFormat formatter = DateFormat();
        final String formatted = formatter.format(now);
        await http.post(
            'https://vuestep-ba76f.firebaseio.com/imagelogs.json',
            body: json.encode({
              'error': response.data,
              'statusCode': response.statusCode,
              'phone': _prefs.getString('phone'),
              'date': formatted,
              'app': 'FaolFuqarolar'
            })
        );
      }
      return response;
    } catch (error) {
      throw error;
    }
  }

  Future<int> sentMessage(String description, int categoryId, double latitude,
      double longitude, String imagePath) async {
    final _prefs = await SharedPreferences.getInstance();
    final phoneNumber = _prefs.getString('phone');
    final _token = _prefs.getString('token');
    final citizenId = _prefs.getInt('userId');
    Response imageResponse = await sentImage(imagePath);
    const url = 'https://api.faol-fuqarolar.uz/api/requests';
    try {
      if (imageResponse.statusCode == 201 || imageResponse.statusCode == 200) {
        final response = await http.post(
            url,
            body: json.encode({
              'citizenId': citizenId,
              'phone': phoneNumber,
              'lat': latitude,
              'lng': longitude,
              'imageId': imageResponse.data['id'],
              'categoryId': categoryId,
              'description': description
            }),
            headers: {
              'Content-type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $_token'
            }
        );
        if (response.statusCode != 202 && response.statusCode != 200) {
          throw HttpException;
        }
        return response.statusCode;
      } else {
        return 1;
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> logOut() async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}