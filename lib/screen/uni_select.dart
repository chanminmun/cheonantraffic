import 'package:flutter/material.dart';
import 'package:hackathon/screen/home.dart';

class UniversitySearch extends StatefulWidget {
  @override
  _UniversitySearchState createState() => _UniversitySearchState();
}

class _UniversitySearchState extends State<UniversitySearch> {
  final List<String> universities = [
    "국립공주대학교",
    "단국대학교",
    "상명대학교",
    "선문대학교",
    "순천향대학교",
    "나사렛대학교",
    "남서울대학교",
    "백석대학교",
    "한국기술교육대학교",
    "호서대학교",
    "백석문화대학교",
  ];

  // 이미지 매핑 (대학교명 -> 이미지 파일)
  final Map<String, String> universityImages = {
    "국립공주대학교": "asset/img/국립공주대학교.png",
    "단국대학교": "asset/img/단국대학교.png",
    "상명대학교": "asset/img/상명대학교.png",
    "선문대학교": "asset/img/선문대학교.png",
    "순천향대학교": "asset/img/순천향대학교.png",
    "나사렛대학교": "asset/img/나사렛대학교.png",
    "남서울대학교": "asset/img/남서울대학교.png",
    "백석대학교": "asset/img/백석대학교.png",
    "한국기술교육대학교": "asset/img/한국기술교육대학교.png",
    "호서대학교": "asset/img/호서대학교.png",
    "백석문화대학교": "asset/img/백석문화대학교.png",
  };

  List<String> filteredUniversities = [];
  TextEditingController searchController = TextEditingController();
  String? selectedUniversity;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterUniversities);
  }

  void _filterUniversities() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredUniversities = [];
      } else {
        filteredUniversities =
            universities.where((univ) => univ.toLowerCase().contains(query)).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 상단에 이미지 추가 (선택된 대학의 이미지)
            selectedUniversity != null
                ? Image.asset(
              universityImages[selectedUniversity!]!,
              height: 200, // 이미지 높이 조정
              width: double.maxFinite, // 화면 너비에 맞게 설정
              fit: BoxFit.fill, // 이미지 비율 유지, 잘릴 수 있음
            )
                : Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300], // 기본 회색 배경
              child: Center(
                child: Text("대학을 선택하세요.", style: TextStyle(fontSize: 18)),
              ),
            ),
            SizedBox(height: 5), // 이미지와 검색창 사이의 간격

            // 검색창
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "대학교 검색",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 20), // 검색창과 리스트 간의 간격

            // 검색 결과 리스트
            Expanded(
              child: filteredUniversities.isNotEmpty
                  ? ListView.builder(
                itemCount: filteredUniversities.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredUniversities[index]),
                    onTap: () {
                      setState(() {
                        selectedUniversity = filteredUniversities[index];
                      });
                    },
                  );
                },
              )
                  : Center(child: Text("검색 결과가 없습니다.")),
            ),
            SizedBox(height: 20),

            // 버튼
            ElevatedButton(
              onPressed: selectedUniversity != null
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(university: selectedUniversity!),
                  ),
                );
              }
                  : null,
              child: Text("다음"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
