import 'package:hackathon/screen/Start.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'firebase_options.dart';
import 'package:hackathon/screen/home.dart';
import 'package:hackathon/fuction/loading.dart';


void main() async {
  KakaoSdk.init(
    nativeAppKey: '06d79aa84235919e715a6e7888a0a5b9',
    javaScriptAppKey: '4ed5bcd9df85cd7496f56172ad4d5e43',
  ); // Kakao SDK 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartScreen()  // 로그인 화면으로 시작
    );
  }
}
