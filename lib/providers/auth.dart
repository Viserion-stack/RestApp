import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  // ignore: non_constant_identifier_names
  String _refreshToken;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    print('TUTAJ POBIERAM TOKENA');
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    //refreshSession();
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=AIzaSyAljMv2uwvuALPY6QTWerJ4ps1-YezusyQ';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _refreshToken = responseData['refreshToken'];

      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      print(_expiryDate.difference(DateTime.now()).inSeconds);
      //_autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'refreshToken': _refreshToken,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      new Timer.periodic(Duration(minutes: 55), (timer) {
        print('ODSWIEZAM TOKENA!');
        //refreshSession();
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signupNewUser');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'verifyPassword');
  }

  Future<bool> tryAutoLogin() async {
    //refreshSession();
    print('TUTAJ PRÓBUJE AUTO LOGINU');
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _refreshToken = extractedUserData['refreshToken'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    print('czas wygaśniecia: ' + expiryDate.toIso8601String());

    notifyListeners();
    //_autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

  // ignore: unused_element
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  Future<void> refreshSession() async {
    print('ODŚWIEZAM TOKENA!');
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    _refreshToken = extractedUserData['refreshToken'];

    print(_refreshToken);
    final url =
        'https://securetoken.googleapis.com/v1/token?key=AIzaSyAljMv2uwvuALPY6QTWerJ4ps1-YezusyQ';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'grant_type': 'refresh_token',
            'refresh_token': _refreshToken,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['id_token'];

      _refreshToken = responseData['refresh_token'];
      _userId = responseData['user_id'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expires_in'],
          ),
        ),
      );
      print('Expiry DATEEEE: ' + _expiryDate.toIso8601String());
      print('REFRESH_TEOKEN: ' + _refreshToken);
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'refreshToken': _refreshToken,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }
}
