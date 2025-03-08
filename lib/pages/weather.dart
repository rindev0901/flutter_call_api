import 'package:flutter/material.dart';
import 'package:flutter_call_api/states/weather.dart';

class MyWeatherPage extends StatefulWidget {
  final String title;
  const MyWeatherPage({super.key, required this.title});
  @override
  State<StatefulWidget> createState() => MyWeatherPageState();
}
