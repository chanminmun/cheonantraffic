import 'package:flutter/material.dart';
import 'package:hackathon/screen/signup.dart';
import 'package:hackathon/screen/uni_select.dart'; // 대학 선택 스크린 import
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:hackathon/login/google_service.dart';
import 'package:hackathon/login/kakao_service.dart';
import 'package:hackathon/config/login_platform.dart';
import 'package:hackathon/config/login_button.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({Key? key}) : super(key: key);

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPlatform _loginPlatform = LoginPlatform.none;

  // 카카오 로그인
  Future<void> _loginWithKakao() async {
    bool success = await KakaoService().login();
    if (success) {
      setState(() {
        _loginPlatform = LoginPlatform.kakao;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UniversitySearch()),
      );
    }
  }

  // 구글 로그인
  Future<void> _loginWithGoogle() async {
    bool success = await GoogleService().login();
    if (success) {
      setState(() {
        _loginPlatform = LoginPlatform.google;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UniversitySearch()),
      );
    }
  }

  // 이메일 로그인
  Future<void> _loginWithEmail() async {
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      await firebase_auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      setState(() {
        _loginPlatform = LoginPlatform.email;
      });

      print('로그인 성공');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UniversitySearch()),
      );
    } catch (error) {
      print('이메일 로그인 실패: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF948BFF)  ,
      body: Stack(
        children: [
          // 상단 이미지
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 90, left: 20),
              height: 300,
              decoration: const BoxDecoration(

              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
          ),
          // 로그인 카드
          Positioned(
            top: 250,
            left: 20,
            right: 20,
            child: Container(
              height: 480.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 이메일 입력
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 비밀번호 입력
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 로그인 버튼
                  ElevatedButton(
                    onPressed: _loginWithEmail,
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  // SNS 로그인
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: LoginButton(
                          imagePath: 'asset/img/kakao_logo.png',
                          onPressed: _loginWithKakao,
                        ),
                      ),
                      Flexible(
                        child: LoginButton(
                          imagePath: 'asset/img/google_logo.png',
                          onPressed: _loginWithGoogle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
