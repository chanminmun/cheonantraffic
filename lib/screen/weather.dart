import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:hackathon/fuction/location.dart';
import 'package:hackathon/fuction/network.dart';

const WEATHER_API_KEY = 'a25688d777ac6f5231ac22104a17f7a8';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late double latitude;
  late double longitude;
  String? weatherDescription;
  double? temperature;
  String cityName = "Loading...";
  DateTime currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      MyLocation myLocation = MyLocation();
      await myLocation.getMyCurrentLocation();

      setState(() {
        latitude = myLocation.latitude2!;
        longitude = myLocation.longitude2!;
      });

      String weatherUrl =
          'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$WEATHER_API_KEY&units=metric';

      Network network = Network(weatherUrl);
      var weatherData = await network.getWeatherData();

      if (weatherData != null) {
        setState(() {
          weatherDescription = weatherData['description'];
          temperature = weatherData['temperature'];
          cityName = weatherData['cityName'] ?? "Unknown Location";
          currentTime = DateTime.now();
        });
      }
    } catch (e) {
      print('날씨 정보를 가져오는 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location, color: Colors.white),
            onPressed: () async {
              await _fetchWeather(); // 실시간 위치 업데이트 및 날씨 갱신
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('위치 및 날씨 정보가 업데이트되었습니다.')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: weatherDescription == null || temperature == null
            ? SpinKitFadingCircle(
          color: Colors.white,
          size: 80.0,
        )
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 30,
              ),
              Text(
                cityName,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${DateFormat('h:mm a - EEEE, d MMM, yyyy').format(currentTime)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 60),
              Text(
                '${temperature!.toStringAsFixed(0)}°C',
                style: const TextStyle(
                  fontSize: 72,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  const Icon(Icons.circle, color: Colors.black87, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    weatherDescription ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
