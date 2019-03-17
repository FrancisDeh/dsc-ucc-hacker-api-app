import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _primaryColor = Color(0xFFFFDE03);

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String _nameError, _emailError, _passwordError;

  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  @override
  void initState() {
    super.initState();

    _authenticateUser();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _primaryColor,
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //logo goes here
                  SizedBox(
                    height: 100.0,
                  ),
                  _appIconStack(),
                  _appTitle(),
                  SizedBox(
                    height: 50.0,
                  ),
                  _appForm(),
                ],
              ),
            )));
  }

  Widget _appForm() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          _nameFormField(),
          SizedBox(
            height: 15.0,
          ),
          _emailFormField(),
          SizedBox(
            height: 15.0,
          ),
          _passwordFormField(),
          SizedBox(
            height: 20.0,
          ),
          _formButton()
        ],
      ),
    );
  }

  Widget _nameFormField() {
    return TextField(
      controller: _nameController,
      keyboardType: TextInputType.text,
      style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          fontSize: 16.0),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        errorText: _nameError,
        labelText: "NAME",
        labelStyle: TextStyle(color: Colors.brown, letterSpacing: 2.0),
        suffixIcon: Icon(
          Icons.person,
          color: Colors.black,
        ),
        filled: true,
      ),
    );
  }

  Widget _emailFormField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          fontSize: 16.0),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        errorText: _emailError,
        labelText: "EMAIL",
        labelStyle: TextStyle(color: Colors.brown, letterSpacing: 2.0),
        suffixIcon: Icon(
          Icons.email,
          color: Colors.black,
        ),
        filled: true,
      ),
    );
  }

  Widget _passwordFormField() {
    return TextField(
      controller: _passwordController,
      keyboardType: TextInputType.text,
      obscureText: true,
      style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          fontSize: 16.0),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: "PASSWORD",
        labelStyle: TextStyle(color: Colors.brown, letterSpacing: 2.0),
        errorText:  _passwordError,
        suffixIcon: Icon(
          Icons.vpn_key,
          color: Colors.black,
        ),
        filled: true,
      ),
    );
  }

  Widget _formButton() {
    return RaisedButton(
      padding: EdgeInsets.all(10.0),
      onPressed: () {
        _logIn();
      },
      child: Text(
        "LOGIN",
        style: TextStyle(
            color: Colors.white,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
            fontSize: 16.0),
      ),
      color: Colors.brown,
    );
  }


  Widget _appIconStack() {
    return Container(
      child: Stack(children: <Widget>[
        _appIconBuilder('D', Colors.red),
        Padding(
          padding: EdgeInsets.only(left: 35.0, top: 10.0),
          child: _appIconBuilder('U', Colors.green),
        ),
        Padding(
          padding: EdgeInsets.only(left: 70.0),
          child: _appIconBuilder('M', Colors.indigo),
        ),
        Padding(
          padding: EdgeInsets.only(left: 105.0, top: 10.0),
          child: _appIconBuilder('A', Colors.deepOrange),
        )
      ]),
    );
  }

  Widget _appIconBuilder(String title, Color color) {
    return Container(
//      margin: const EdgeInsets.only(left: 35.0, top: 10.0),
      alignment: Alignment.center,
      height: 50.0,
      width: 50.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          color: color,
          boxShadow: [BoxShadow(color: Colors.black)]),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 30.0,
        ),
      ),
    );
  }

  Widget _appTitle() {
    return Container(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(
        'DSC UCC Mobile App',
        style: TextStyle(
            letterSpacing: 2.0, fontSize: 17.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  _logIn () {
    if(_nameController.text.isEmpty) {
      setState(() {
        _nameError = "Name cannot be empty";
      });
      return;
    } else {
      setState(() {
        _nameError = null;
      });
    }

    if(_emailController.text.isEmpty) {
      setState(() {
        _emailError = "Email cannot be empty";
      });
      return;
    } else {
      setState(() {
        _emailError = null;
      });
    }

    if(_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = "Password cannot be empty";
      });
      return;
    } else {
      setState(() {
        _passwordError = null;
      });
    }
    print('successful');
    _saveUserInfo();
  }

  _saveUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('status', true);
    prefs.setString('name', _nameController.text);
    prefs.setString('email', _emailController.text);
    prefs.setString('password', _passwordController.text);

    Navigator.pushReplacementNamed(context, '/main');

  }

  _authenticateUser () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('status') ?? false;
    print(isLoggedIn);
    if(isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/main');
    }

  }
}
