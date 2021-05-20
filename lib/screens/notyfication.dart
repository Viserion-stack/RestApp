import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_login/flutter_login.dart';

import 'dart:async';

// ignore: duplicate_import
import 'package:flutter/material.dart';
import '../providers/auth.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:restauranttt/widgets/app_drawer.dart';
import 'package:firebase_core/firebase_core.dart';

class Notyfi extends StatefulWidget {
  static const routeName = '/notyfication';
  @override
  _NotyfiState createState() => _NotyfiState();
}

enum AuthMode { Signup, Login }

class _NotyfiState extends State<Notyfi> {
  @override
  void initState() {
    final fbm = FirebaseMessaging();
    Firebase.initializeApp();
    fbm.requestNotificationPermissions();

    fbm.configure(onMessage: (msg) {
      print(msg);
      return;
    }, onLaunch: (msg) {
      print(msg);
      return;
    }, onResume: (msg) {
      print(msg);
      return;
    });

    super.initState();
  }

  Future<void> getToken() async {
    // String _token;
    // // ignore: non_constant_identifier_names
    // String _refresh_token = Provider.of<Auth>(context).reftok;
    // DateTime _expiryDate;
    // String _userId;

    // final url =
    //     'https://securetoken.googleapis.com/v1/token?key=AIzaSyAljMv2uwvuALPY6QTWerJ4ps1-YezusyQ';
    // try {
    //   final response = await http.post(
    //     url,
    //     body: json.encode(
    //       {
    //         'grant_type': 'refresh_token',
    //         'refresh_token': _refresh_token,
    //       },
    //     ),
    //   );
    //   final responseData = json.decode(response.body);
    //   if (responseData['error'] != null) {
    //     throw HttpException(responseData['error']['message']);
    //   }
    //   _token = responseData['id_token'];

    //   _refresh_token = responseData['refresh_token'];

    //   _userId = responseData['user_id'];
    //   _expiryDate = DateTime.now().add(
    //     Duration(
    //       seconds: int.parse(
    //         responseData['expires_in'],
    //       ),
    //     ),
    //   );
    //   print('Expiry DATEEEE: ' + _expiryDate.toIso8601String());
    //   print('REFRESH_TEOKEN: ' + _refresh_token);
    //   print('TEOKEN: ' + _token);
    //   print('USERID: ' + _userId);

    //   final prefs = await SharedPreferences.getInstance();
    //   final userData = json.encode(
    //     {
    //       'token': _token,
    //       'refresh_Token': _refresh_token,
    //       'userId': _userId,
    //       'expiryDate': _expiryDate.toIso8601String(),
    //     },
    //   );
    //   prefs.setString('userData', userData);
    // } catch (error) {
    //   throw error;
    // }
    // Timer.periodic(Duration(seconds: 3), (timer) {
    //   print('HI!');
    // });

    // const twentyMillis = const Duration(seconds: 2);
    // new Timer(twentyMillis, () => print('hi!'));
    //Timer(Duration(seconds: 10), Provider.of<Auth>(context).refreshSession);
    Provider.of<Auth>(context).refreshSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('...'),
      ),
      drawer: AppDrawer(),
      body: IconButton(
        icon: Icon(Icons.accessibility_new),
        onPressed: () {
          getToken();
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;

  AuthMode _authMode = AuthMode.Login;

  String _email;

  String _password;

  @override
  Widget build(BuildContext context) {
    void _showErrorDialog(String message) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Wystąpił Błąd!'),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text('Okej'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }

    Future<void> _submit(String email, String password) async {
      //UserCredential authResult;
      try {
        if (_authMode == AuthMode.Login) {
          // Log user in
          _auth.signInWithEmailAndPassword(email: email, password: password);
        } else {
          // Sign user up
          _auth.createUserWithEmailAndPassword(
              email: email, password: password);
        }
      } catch (error) {
        var errorMessage = 'Niepowodzenie autoryzacji';
        if (error.toString().contains('EMAIL_EXISTS')) {
          errorMessage = 'Ten email jest już w użyciu.';
        } else if (error.toString().contains('INVALID_EMAIL')) {
          errorMessage = 'Niepoprawny adres email';
        } else if (error.toString().contains('WEAK_PASSWORD')) {
          errorMessage = 'Za słabe hasło.';
        } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
          errorMessage = 'Nie znaleziono adresu email.';
        } else if (error.toString().contains('INVALID_PASSWORD')) {
          errorMessage = 'Niepoprawne hasło.';
        }
        _showErrorDialog(errorMessage);
      }
    }

    return FlutterLogin(
      title: 'ECORP',
      logo: 'assets/images/ecorp.png',
      // ignore: missing_return
      emailValidator: (value) {
        _email = value.trim();
        print(_email);
      },
      // ignore: missing_return
      passwordValidator: (value) {
        _password = value.trim();
        print(_password);
      },
      // ignore: missing_return
      onLogin: (_) {
        // _authMode = AuthMode.Login;
        // _submit(_email, _password);
        Provider.of<Auth>(context).tryAutoLogin();
        return;
      },

      // ignore: missing_return
      onSignup: (_) {
        _authMode = AuthMode.Signup;
        _submit(_email, _password);
      },

      // onSubmitAnimationCompleted: () {
      //   Navigator.of(context)
      //       .pushReplacementNamed(ProductsOverviewScreen.routeName);
      // },
      onRecoverPassword: (_) => Future(null),
    );
  }
}
