import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_call_api/models/weather.dart';
import 'package:flutter_call_api/pages/weather.dart';
import 'package:http/http.dart' as http;

class MyWeatherPageState extends State<MyWeatherPage> {
  final TextEditingController _locationController = TextEditingController();

  late Future<WeatherResponse> futureWeather;
  Timer? _debounce;

  WeatherResponse parseWeatherResponse(String responseJson) {
    final Map<String, dynamic> jsonMap = jsonDecode(responseJson);
    return WeatherResponse.fromJson(jsonMap);
  }

  Future<WeatherResponse> fetchWeatherWithLocation({
    String location = "Ho Chi Minh City",
  }) async {
    try {
      Uri url = Uri.parse(
        "https://weatherapi-com.p.rapidapi.com/current.json?q=${location.isEmpty ? "Ho Chi Minh City" : location}",
      );

      var response = await http.get(
        url,
        headers: {
          "x-rapidapi-host": "weatherapi-com.p.rapidapi.com",
          "x-rapidapi-key":
              "40cf7ffcaemsha500262f5e582f1p1613f5jsn4d2286c415ce",
        },
      );
      if (response.statusCode == 200) {
        return parseWeatherResponse(response.body);
      } else {
        throw Exception("Failed to load weather data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Failed to fetch weather data: $e");
    }
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // do something with query
      futureWeather = fetchWeatherWithLocation(location: query);
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    futureWeather = fetchWeatherWithLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1504608524841-42fe6f032b4b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
            ), // Dynamic background image
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Search Container
            Container(
              margin: EdgeInsets.only(top: 50),
              width: width * 0.8,
              height: height * 0.07,
              padding: EdgeInsets.only(left: 0.03 * width, right: 0.03 * width),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
                border: Border.all(color: Colors.grey),
              ),
              child: Center(
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.location_on, color: Colors.grey),
                    SizedBox(width: width * 0.04),
                    Expanded(
                      child: TextField(
                        controller: _locationController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Ho Chi Minh',
                          hintStyle: TextStyle(color: Colors.grey),
                          border:
                              InputBorder.none, // Remove the default underline
                          suffixIcon:
                              _locationController.text.isNotEmpty
                                  ? IconButton(
                                    icon: Icon(Icons.clear, color: Colors.grey),
                                    onPressed: () {
                                      _locationController
                                          .clear(); // Clear the text
                                      _onSearchChanged(
                                        "",
                                      ); // Trigger the search change
                                    },
                                  )
                                  : null, // Show the clear icon only when there's text
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // FutureBuilder for Weather Data
            Expanded(
              // Wrap FutureBuilder in Expanded
              child: FutureBuilder(
                future: futureWeather,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a loading indicator while fetching data
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // Show an error message if the fetch fails
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    // Handle case where no data is available
                    return Center(child: Text("Data not available"));
                  }

                  // Get the weather response
                  var weatherResponse = snapshot.data!;
                  // Display the weather data
                  return SingleChildScrollView(
                    // Use SingleChildScrollView for scrollable content
                    child: Column(
                      children: [
                        // Location and Temperature
                        Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${weatherResponse.location.name}, ${weatherResponse.location.country}',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10),
                              Text(
                                '${weatherResponse.current.tempC}°C',
                                style: TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                weatherResponse.current.condition.text,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 10),
                              Image.network(
                                'https:${weatherResponse.current.condition.icon}',
                                width: 64,
                                height: 64,
                              ),
                            ],
                          ),
                        ),
                        // Additional Weather Details
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(50),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  WeatherDetail(
                                    icon: Icons.water_drop,
                                    label: 'Humidity',
                                    value:
                                        '${weatherResponse.current.humidity}%',
                                  ),
                                  WeatherDetail(
                                    icon: Icons.air,
                                    label: 'Wind',
                                    value:
                                        '${weatherResponse.current.windKph} km/h',
                                  ),
                                  WeatherDetail(
                                    icon: Icons.thermostat,
                                    label: 'Feels Like',
                                    value:
                                        '${weatherResponse.current.feelslikeC}°C',
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  WeatherDetail(
                                    icon: Icons.visibility,
                                    label: 'Visibility',
                                    value:
                                        '${weatherResponse.current.visKm} km',
                                  ),
                                  WeatherDetail(
                                    icon: Icons.grain,
                                    label: 'Precipitation',
                                    value:
                                        '${weatherResponse.current.precipMm} mm',
                                  ),
                                  WeatherDetail(
                                    icon: Icons.wb_sunny,
                                    label: 'UV Index',
                                    value: '${weatherResponse.current.uv}',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherDetail({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 16, color: Colors.white)),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
