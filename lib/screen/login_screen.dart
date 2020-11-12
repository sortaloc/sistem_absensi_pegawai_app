import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/forgot_pass_screen.dart';
import 'package:spo_balaesang/screen/home_screen.dart';
import 'package:spo_balaesang/utils/view_util.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  double getSmallDiameter(BuildContext context) =>
      MediaQuery.of(context).size.width * 2 / 3;

  double getBigDiameter(BuildContext context) =>
      MediaQuery.of(context).size.width * 7 / 8;

  bool _isLoading = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isPasswordVisible = false;

  Widget _buildPhoneForm() {
    return TextFormField(
      validator: (String value) {
        if (value.isEmpty) {
          return 'Nomor telpon tidak boleh kosong!';
        }
        return null;
      },
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent)),
          prefixIcon: Icon(
            Icons.phone_android,
            color: Colors.blueAccent[700],
          ),
          labelText: 'Nomor Telpon',
          labelStyle: TextStyle(color: Colors.blueAccent[200])),
      style: TextStyle(color: Colors.blueAccent[700]),
    );
  }

  Widget _buildPasswordForm() {
    return TextFormField(
      validator: (String value) {
        if (value.isEmpty) {
          return 'Kata sandi tidak boleh kosong!';
        }
        return null;
      },
      obscureText: !isPasswordVisible,
      controller: _passwordController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent)),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
            child: Icon(
              isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.blueAccent[700],
            ),
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: Colors.blueAccent[700],
          ),
          labelText: 'Password',
          labelStyle: TextStyle(color: Colors.blueAccent[200])),
      style: TextStyle(color: Colors.blueAccent[700]),
    );
  }

  Future<String> getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String model;
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      model = androidInfo.model;
    }
    return model;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: <Widget>[
          Positioned(
            right: -getSmallDiameter(context) / 3,
            top: -getSmallDiameter(context) / 3,
            child: Container(
              width: getSmallDiameter(context),
              height: getSmallDiameter(context),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [Colors.lightBlue[200], Colors.blueAccent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
              ),
            ),
          ),
          Positioned(
            left: -getBigDiameter(context) / 4,
            top: -getBigDiameter(context) / 4,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/logo/logo.png',
                    width: 200,
                  ),
                  Text(
                    'Sistem Absensi Pegawai',
                    style: TextStyle(fontSize: 12.0, color: Colors.white),
                  ),
                ],
              ),
              width: getBigDiameter(context),
              height: getBigDiameter(context),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [Colors.blueAccent[700], Colors.blueAccent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ListView(
              children: <Widget>[
                ClipRRect(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5.0, 350, 5.0, 10),
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 25),
                    child: Card(
                      elevation: 6.0,
                      child: Column(
                        children: <Widget>[
                          _buildPhoneForm(),
                          _buildPasswordForm()
                        ],
                      ),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: EdgeInsets.only(right: 20.0, bottom: 20.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ForgotPassScreen(),
                              fullscreenDialog: true),
                        );
                      },
                      child: Text(
                        'Lupa Password?',
                        style: TextStyle(color: Colors.blue[800]),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 40.0,
                        child: Container(
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10.0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10.0),
                              onTap: _isLoading
                                  ? null
                                  : () async {
                                      final SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      final String _deviceName =
                                          await getDeviceInfo();
                                      final Map<String, dynamic> data =
                                          <String, dynamic>{
                                        'phone': _phoneController.value.text,
                                        'password':
                                            _passwordController.value.text,
                                        'device_name': _deviceName
                                      };
                                      try {
                                        final dataRepository =
                                            Provider.of<DataRepository>(context,
                                                listen: false);
                                        Response response =
                                            await dataRepository.login(data);
                                        final Map<String, dynamic> result =
                                            jsonDecode(response.body);
                                        if (response.statusCode == 200) {
                                          prefs.setString(
                                              'token',
                                              jsonEncode(
                                                  result['data']['token']));
                                          prefs.setString('user',
                                              jsonEncode(result['data']));
                                          print(result['data']['token']);
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => HomeScreen()),
                                              (route) => false);
                                        } else {
                                          showErrorDialog(context, result);
                                        }
                                      } on SocketException catch (e) {
                                        print(e.message);
                                      } catch (e) {
                                        print(e);
                                      } finally {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    },
                              child: Center(
                                child: _isLoading
                                    ? SizedBox(
                                        height: 30.0,
                                        width: 30.0,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'MASUK',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: LinearGradient(
                                colors: [
                                  Colors.lightBlue[700],
                                  Colors.lightBlue[900]
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'v0.1.0',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Sistem Presensi Online by Banua Coders ',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}