import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao_user;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hackathon/screen/weather.dart';

class HomeScreen extends StatefulWidget {
  final String university;

  const HomeScreen({Key? key, required this.university}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  String _userProfilePicUrl = '';
  String _userProfilePicUrl1 = '';

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _getGoogleUserInfo();
    _getKakaoUserInfo();
    _getUserInfo();
  }

  void _getKakaoUserInfo() async {
    try {
      kakao_user.User kakaoUser = await kakao_user.UserApi.instance.me();
      String userName = kakaoUser.kakaoAccount?.profile?.nickname ?? '사용자 이름 없음';
      String userProfilePicUrl = kakaoUser.kakaoAccount?.profile?.thumbnailImageUrl ?? '';

      setState(() {
        _userName = userName;
        _userProfilePicUrl1 = userProfilePicUrl;
      });
    } catch (error) {
      print("카카오톡 사용자 정보 가져오기 실패: $error");
    }
  }

  Future<void> _getGoogleUserInfo() async {
    try {
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        firebase_auth.UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
        firebase_auth.User? user = userCredential.user;

        if (user != null) {
          String userName = user.displayName ?? '사용자 이름 없음';
          String userProfilePicUrl = user.photoURL ?? 'https://example.com/default_profile_pic.png';

          _updateUserInfoInFirestore(userName, userProfilePicUrl);

          setState(() {
            _userName = userName;
            _userProfilePicUrl = userProfilePicUrl;
          });
        }
      }
    } catch (error) {
      print("구글 사용자 정보 가져오기 실패: $error");
    }
  }

  void _updateUserInfoInFirestore(String userName, String userProfilePicUrl) async {
    firebase_auth.User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': userName,
        'profilePicUrl': userProfilePicUrl,
        'lastLogin': Timestamp.now(),
      }, SetOptions(merge: true));
    }
  }

  void _getUserInfo() async {
    firebase_auth.User? user = _firebaseAuth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['name'] ?? '사용자';
          _userProfilePicUrl = userDoc['profilePicUrl'] ?? '';
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      var isKakaoLoggedIn = await _checkKakaoLogin();
      if (isKakaoLoggedIn) {
        await kakao_user.UserApi.instance.logout();
        print('카카오 로그아웃 성공');
      } else {
        print('카카오는 로그인되지 않음');
      }
    } catch (error) {
      print('카카오 로그아웃 오류: $error');
    }

    GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
    if (googleUser != null) {
      await _googleSignIn.signOut();
      print('구글 로그아웃 성공');
    } else {
      print('구글은 로그인되지 않음');
    }

    firebase_auth.User? firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      await _firebaseAuth.signOut();
      print('Firebase 로그아웃 성공');
    } else {
      print('Firebase는 로그인되지 않음');
    }
  }

  Future<bool> _checkKakaoLogin() async {
    try {
      final tokenInfo = await kakao_user.UserApi.instance.accessTokenInfo();
      return tokenInfo != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'asset/img/${widget.university}.png',
              height: 50,
            ),
            IconButton(
              icon: Icon(Icons.chat_bubble_outline),
              onPressed: () {
                _logout(); // 로그아웃 처리
              },
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Color(0xFF948BFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _userProfilePicUrl.isNotEmpty
                        ? NetworkImage(_userProfilePicUrl) as ImageProvider
                        : (_userProfilePicUrl1.isNotEmpty
                        ? NetworkImage(_userProfilePicUrl1) as ImageProvider
                        : AssetImage("asset/img/anonymous.png")),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        widget.university,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            WeatherWidget(),
            SizedBox(height: 30),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              children: [
                _buildGridButton(context, '실시간 교통 상황', '/traffic'),
                _buildGridButton(context, '셔틀 시간표', '/shuttle'),
                _buildGridButton(context, '지금 출발한다면?', '/길찾기'),
                _buildGridButton(context, 'ㅁㄹ', '/ㅁㄹ'),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF948BFF),
        currentIndex: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          if (index == 0) {
            // 목록
          } else if (index == 1) {
            // 홈
          } else if (index == 2) {
            // 세팅
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '목록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }

  Widget _buildGridButton(BuildContext context, String title, String? route) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFA7C7E7),
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        onPressed: route != null
            ? () {
          Navigator.pushNamed(context, route);
        }
            : null,
        child: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class WeatherWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String temperature = "25°C";
    String condition = "맑음";
    String city = "서울";

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WeatherScreen()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.wb_sunny, size: 40, color: Colors.white),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  "$temperature, $condition",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}