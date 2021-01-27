import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:markets_deliveryboy/src/elements/custom_text.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/app_config.dart' as config;

class SignUpWidget extends StatefulWidget {
  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends StateMVC<SignUpWidget> {
  UserController _con;
  bool _loginUiState = true;
  Timer _timer;
  int _start;
  String _dialCode = "254";
  User _firebaseUser;
  String _status = "";
  String _countDownStatus = "";
  TextEditingController _otpController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  ProgressDialog pr;
  AuthCredential _phoneAuthCredential;
  String _verificationId;
  int _code;

  _SignUpWidgetState() : super(UserController()) {
    _con = controller;
  }

  void _startTimer() {
    _start = 60;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
            _countDownStatus = "Resend Code";
          } else {
            _start = _start - 1;
            _countDownStatus = _start.toString();
          }
        },
      ),
    );
    pr.hide();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _con.scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Positioned(
              top: 0,
              child: Container(
                width: config.App(context).appWidth(100),
                height: config.App(context).appHeight(29.5),
                decoration: BoxDecoration(color: Theme.of(context).accentColor),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(29.5) - 140,
              child: Container(
                width: config.App(context).appWidth(84),
                height: config.App(context).appHeight(29.5),
                child: Text(
                  S.of(context).lets_start_with_register,
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      .merge(TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(29.5) - 50,
              child: Container(
                height: MediaQuery.of(context).size.height - 200,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 50,
                        color: Theme.of(context).hintColor.withOpacity(0.2),
                      )
                    ]),
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding: EdgeInsets.symmetric(vertical: 50, horizontal: 27),
                width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                child: _loginUiState
                    ? Form(
                        key: _con.loginFormKey,
                        child: ListView(
                          shrinkWrap: true,
                          children: <Widget>[
                            TextFormField(
                              keyboardType: TextInputType.text,
                              onSaved: (input) => _con.user.name = input,
                              validator: (input) => input.length < 3
                                  ? S.of(context).should_be_more_than_3_letters
                                  : null,
                              decoration: InputDecoration(
                                labelText: S.of(context).full_name,
                                labelStyle: TextStyle(
                                    color: Theme.of(context).accentColor),
                                contentPadding: EdgeInsets.all(12),
                                hintText: S.of(context).john_doe,
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.7)),
                                prefixIcon: Icon(Icons.person_outline,
                                    color: Theme.of(context).accentColor),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.5))),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                              ),
                            ),
                            SizedBox(height: 30),
                            TextFormField(
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.number,
                              onSaved: (input) => _con.user.phone = input,
                              validator: (input) => input.length < 9
                                  ? S.of(context).should_be_more_than_3_letters
                                  : null,
                              decoration: InputDecoration(
                                labelText: S.of(context).phone,
                                labelStyle: TextStyle(
                                    color: Theme.of(context).accentColor),
                                contentPadding: EdgeInsets.all(12),
                                hintText: S.of(context).phone,
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.7)),
                                prefixIcon: Icon(Icons.phone,
                                    color: Theme.of(context).accentColor),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.5))),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                              ),
                            ),
                            SizedBox(height: 30),
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              onSaved: (input) => _con.user.email = input,
                              validator: (input) => !input.contains('@')
                                  ? S.of(context).should_be_a_valid_email
                                  : null,
                              decoration: InputDecoration(
                                labelText: S.of(context).email,
                                labelStyle: TextStyle(
                                    color: Theme.of(context).accentColor),
                                contentPadding: EdgeInsets.all(12),
                                hintText: 'johndoe@gmail.com',
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.7)),
                                prefixIcon: Icon(Icons.alternate_email,
                                    color: Theme.of(context).accentColor),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.5))),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                              ),
                            ),
                            SizedBox(height: 30),
                            TextFormField(
                              textCapitalization: TextCapitalization.characters,
                              keyboardType: TextInputType.text,
                              onSaved: (input) =>
                                  _con.user.registration_number = input,
                              validator: (input) => input.length < 3
                                  ? S.of(context).should_be_more_than_3_letters
                                  : null,
                              decoration: InputDecoration(
                                labelText: S.of(context).regno,
                                labelStyle: TextStyle(
                                    color: Theme.of(context).accentColor),
                                contentPadding: EdgeInsets.all(12),
                                hintText: 'KMW0001',
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.7)),
                                prefixIcon: Icon(Icons.bike_scooter,
                                    color: Theme.of(context).accentColor),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.5))),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                              ),
                            ),
                            SizedBox(height: 30),
                            TextFormField(
                              keyboardType: TextInputType.text,
                              onSaved: (input) =>
                                  _con.user.license_number = input,
                              validator: (input) => input.length < 3
                                  ? S.of(context).should_be_more_than_3_letters
                                  : null,
                              decoration: InputDecoration(
                                labelText: S.of(context).license_number,
                                labelStyle: TextStyle(
                                    color: Theme.of(context).accentColor),
                                contentPadding: EdgeInsets.all(12),
                                hintText: 'License Number',
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.7)),
                                prefixIcon: Icon(Icons.app_registration,
                                    color: Theme.of(context).accentColor),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.5))),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                              ),
                            ),
                            SizedBox(height: 30),
                            TextFormField(
                              obscureText: _con.hidePassword,
                              onSaved: (input) => _con.user.password = input,
                              validator: (input) => input.length < 6
                                  ? S.of(context).should_be_more_than_6_letters
                                  : null,
                              decoration: InputDecoration(
                                labelText: S.of(context).password,
                                labelStyle: TextStyle(
                                    color: Theme.of(context).accentColor),
                                contentPadding: EdgeInsets.all(12),
                                hintText: '••••••••••••',
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.7)),
                                prefixIcon: Icon(Icons.lock_outline,
                                    color: Theme.of(context).accentColor),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _con.hidePassword = !_con.hidePassword;
                                    });
                                  },
                                  color: Theme.of(context).focusColor,
                                  icon: Icon(_con.hidePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.5))),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                              ),
                            ),
                            SizedBox(height: 30),
                            BlockButtonWidget(
                              text: Text(
                                S.of(context).register,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                              color: Theme.of(context).accentColor,
                              onPressed: () {
                                // _con.register();
                                _submitPhoneNumber();
                              },
                            ),
                            SizedBox(height: 15),
                            FlatButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/Login');
                              },
                              textColor: Theme.of(context).hintColor,
                              child: Text(
                                  S.of(context).i_have_account_back_to_login),
                            )
//                      FlatButton(
//                        onPressed: () {
//                          Navigator.of(context).pushNamed('/MobileVerification');
//                        },
//                        padding: EdgeInsets.symmetric(vertical: 14),
//                        color: Theme.of(context).accentColor.withOpacity(0.1),
//                        shape: StadiumBorder(),
//                        child: Text(
//                          'Register with Google',
//                          textAlign: TextAlign.start,
//                          style: TextStyle(
//                            color: Theme.of(context).accentColor,
//                          ),
//                        ),
//                      ),
                          ],
                        ),
                      )
                    : Form(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            CustomText(
                                text: "Verify your number",
                                size: 24,
                                weight: FontWeight.bold),
                            SizedBox(height: 20),
                            Text(
                              "To complete your phone number verification, \nplease enter the 6-digit activation code.",
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(30, 30, 30, 10),
                              child: TextFormField(
                                controller: _otpController,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Enter code';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  labelText: "Enter code", //prefixIcon
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: ButtonTheme(
                                minWidth: 200.0,
                                height: 40.0,
                                child: RaisedButton(
                                  color: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.blue)),
                                  textColor: Colors.white,
                                  onPressed: () async {
                                    // Validate returns true if the form is valid, or false
                                    pr = new ProgressDialog(context,
                                        type: ProgressDialogType.Normal,
                                        isDismissible: true);
                                    pr.style(message: 'Please wait ...');
                                    pr.show();
                                    try {
                                      final result =
                                          await InternetAddress.lookup(
                                              'google.com');
                                      pr.hide();
                                      if (result.isNotEmpty &&
                                          result[0].rawAddress.isNotEmpty) {
                                        _submitOTP();
                                      } else {
                                        _noInternetShowDialog();
                                        return false;
                                      }
                                    } on SocketException catch (_) {
                                      _noInternetShowDialog();
                                      print('not connected');
                                      return false;
                                    }
                                  },
                                  child: Text(
                                    'Verify',
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              _status,
                              style: TextStyle(fontSize: 15, color: Colors.red),
                            ),
                            GestureDetector(
                              onTap: () => setState(() {
                                if (_start < 1) {
                                  _submitPhoneNumber();
                                }
                              }),
                              child: _loginUiState
                                  ? Text("")
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text('resend code? '),
                                        Text(
                                          '$_countDownStatus',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.green),
                                        )
                                      ],
                                    ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _loginUiState = true;
                                });
                              },
                              child: Text("Back"),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            // Positioned(
            //   bottom: 10,
            //   child: FlatButton(
            //     onPressed: () {
            //       Navigator.of(context).pushNamed('/Login');
            //     },
            //     textColor: Theme.of(context).hintColor,
            //     child: Text(S.of(context).i_have_account_back_to_login),
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  Future<void> _submitPhoneNumber() async {
    // pr.show();
    setState(() {
      _status = "";
    });

    /// NOTE: Either append your phone number country code or add in the code itself
    /// Since I'm in India we use "+91 " as prefix `phoneNumber`
    String phoneNumber =
        "+254" + _phoneNumberController.text.toString().trim();
    print("HAPA $phoneNumber");

    SharedPreferences prefs = await SharedPreferences.getInstance();

    /// The below functions are the callbacks, separated so as to make code more redable
    void verificationCompleted(AuthCredential phoneAuthCredential) async {
      _firebaseUser = (await FirebaseAuth.instance
              .signInWithCredential(phoneAuthCredential))
          .user;
      _loginUserToHomePage(_firebaseUser);
    }

    void verificationFailed(FirebaseAuthException error) {
      setState(() {
        _status = 'Invalid code/invalid authentication';
        _countDownStatus = 'verification Failed';
        _loginUiState = true;
      });
      print(error);
    }

    void codeSent(String verificationId, [int code]) {
      this._verificationId = verificationId;
      // print(verificationId);
      this._code = code;
      setState(() {
        _loginUiState = false;
        _startTimer();
      });
    }

    void codeAutoRetrievalTimeout(String verificationId) {
      // print('codeAutoRetrievalTimeout');
//      setState(() {
//        _countDownStatus += 'Timeout\n';
//      });
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      /// Make sure to prefix with your country code
      phoneNumber: phoneNumber,

      /// `seconds` didn't work. The underlying implementation code only reads in `millisenconds`
      timeout: Duration(milliseconds: 10000),

      /// If the SIM (with phoneNumber) is in the current device this function is called.
      /// This function gives `AuthCredential`. Moreover `login` function can be called from this callback
      verificationCompleted: verificationCompleted,

      /// Called when the verification is failed
      verificationFailed: verificationFailed,

      /// This is called after the OTP is sent. Gives a `verificationId` and `code`
      codeSent: codeSent,

      /// After automatic code retrival `tmeout` this function is called
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    ); // All the callbacks are above
  }

  void _submitOTP() {
    pr.show();

    /// get the `smsCode` from the user
    String smsCode = _otpController.text.toString().trim();

    /// when used different phoneNumber other than the current (running) device
    /// we need to use OTP to get `phoneAuthCredential` which is inturn used to signIn/login
    this._phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: this._verificationId, smsCode: smsCode);
    _login();
  }

  Future<void> _login() async {
    /// This method is used to login the user
    /// `AuthCredential`(`_phoneAuthCredential`) is needed for the signIn method
    /// After the signIn method from `AuthResult` we can get `FirebaserUser`(`_firebaseUser`)
    try {
      await FirebaseAuth.instance
          .signInWithCredential(this._phoneAuthCredential)
          .then((UserCredential authRes) {
        _firebaseUser = authRes.user;
      });
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setString('userUid', _firebaseUser.uid.toString());
      // prefs.setString('userPhone', _firebaseUser.phoneNumber.toString());
      _loginUserToHomePage(_firebaseUser);
    } catch (e) {
      setState(() {
        _status = 'Unable to login, Try Again later\n';
      });
      // print(e.toString());
    }
  }

  //INTERNET CHECK
  void _noInternetShowDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text("You are disconnected to the internet"),
              content: new Text("Please check your internet connection"),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: new Text("Close"))
              ]);
        });
  }

  void _loginUserToHomePage(User firebaseUser) {
    ///HERE NOW
    _con.register();
  }
}
