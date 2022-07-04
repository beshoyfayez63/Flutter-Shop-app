import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/models/http_exception.dart';

import '../providers/auth.dart';

enum AuthMode { signup, login }

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  AuthMode _authMode = AuthMode.login;

  Map<String, String> _authData = {'email': '', 'password': ''};

  var _isLoading = false;

  final _passwordController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error Occurred'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(false);
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.login) {
        await Provider.of<Auth>(context, listen: false)
            .login(_authData['email']!, _authData['password']!);
      } else {
        await Provider.of<Auth>(context, listen: false)
            .signup(_authData['email']!, _authData['password']!);
      }
    } on HttpException catch (err) {
      var errorMessage = 'Authantication Failed.';
      if (err.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (err.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not valid email address.';
      } else if (err.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This Password is too weak.';
      } else if (err.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (err.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
    } catch (err) {
      const errorMessage = 'Something went wrong. Please try again later!!';
      _showErrorDialog(errorMessage);
    }
    // setState(() {
    //   _isLoading = false;
    // });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        // height: _authMode == AuthMode.signup ? 320 : 260, // debug here
        // constraints:
        //     BoxConstraints(minHeight: _authMode == AuthMode.signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  cursorColor: theme.primaryColor,
                  decoration: InputDecoration(
                    labelText: 'E-Mail',
                    labelStyle: TextStyle(color: theme.primaryColor),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme.primaryColor),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Invalid email';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) {
                    _authData['email'] = value!;
                  },
                ),
                TextFormField(
                  cursorColor: theme.primaryColor,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: theme.primaryColor),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme.primaryColor),
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Password is too short';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value!;
                  },
                ),
                if (_authMode == AuthMode.signup)
                  TextFormField(
                    cursorColor: theme.primaryColor,
                    enabled: _authMode == AuthMode.signup,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(color: theme.primaryColor),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: theme.primaryColor),
                      ),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Password do not match!';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      _authData['password'] = value!;
                    },
                  ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    // clipBehavior: Clip.hardEdge,
                    onPressed: _submit,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 8,
                        ),
                      ),
                      // foregroundColor: MaterialStateProperty.all<Color>(
                      //     theme.primaryColor),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        theme.primaryColor,
                      ),
                    ),

                    child: Text(
                      _authMode == AuthMode.login ? 'Login' : 'Sign up',
                    ),
                  ),
                TextButton(
                  // clipBehavior: Clip.hardEdge,
                  onPressed: _switchAuthMode,
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                      theme.primaryColor,
                    ),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 4,
                    )),
                  ),

                  child: Text(
                    '${_authMode == AuthMode.login ? 'Login' : 'Sign up'} Instead',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
