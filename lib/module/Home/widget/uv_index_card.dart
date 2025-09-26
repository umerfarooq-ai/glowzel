import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Constant/app_color.dart';
import 'circle1_widget.dart';

class UVIndexCard extends StatefulWidget {
  @override
  _UVIndexCardState createState() => _UVIndexCardState();
}

class _UVIndexCardState extends State<UVIndexCard> {
  double? _uvIndex;
  bool _loading = true;
  String? _error;
  String? recommendedSPF;
  String? exposureTime;
  String? goldenHour;
  String daytime = 'N/A';

  @override
  void initState() {
    super.initState();
    _restoreUVState();
  }

  Future<void> _restoreUVState() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('uv_enabled') ?? false;
    if (enabled) {
      _fetchUVIndex();
    }
  }

  Future<void> _fetchUVIndex() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permission denied';
          _loading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final dio = Dio();

      final response = await dio.get(
        'https://api.openuv.io/api/v1/uv',
        queryParameters: {
          'lat': position.latitude,
          'lng': position.longitude,
        },
        options: Options(
          headers: {
            'x-access-token': 'openuv-131oo4rmdn4e2vp-io',
          },
        ),
      );

      print('📡 UV Response Status: ${response.statusCode}');
      print('📡 UV Response Data: ${response.data}');

      final data = response.data['result'];

      final uv = (data['uv'] as num?)?.toDouble() ?? 0.0;
      final sunInfo = data['sun_info']?['sun_times'];

      DateTime? sunriseUtc = sunInfo?['sunrise'] != null ? DateTime.parse(sunInfo['sunrise']) : null;
      DateTime? sunsetUtc = sunInfo?['sunset'] != null ? DateTime.parse(sunInfo['sunset']) : null;

      DateTime? sunrise = sunriseUtc?.toLocal();
      DateTime? sunset = sunsetUtc?.toLocal();

      String goldenHourValue = 'N/A';
      String daytimeValue = 'N/A';

      if (sunrise != null && sunset != null) {
        final now = DateTime.now();

        bool isDayTime = now.isAfter(sunrise) && now.isBefore(sunset);

        DateTime golden;
        if (isDayTime) {
          golden = sunrise.add(Duration(hours: 1));
        } else {
          golden = sunset.subtract(Duration(hours: 1));
        }

        goldenHourValue = DateFormat.Hm().format(golden);

        final daytimeDuration = sunset.difference(sunrise);
        final daytimeHours = daytimeDuration.inHours;
        final daytimeMinutes = daytimeDuration.inMinutes % 60;

        daytimeValue = '${daytimeHours}h ${daytimeMinutes}m';
      }

      setState(() {
        _uvIndex = uv;
        recommendedSPF = _getRecommendedSPF(uv);
        exposureTime = _getSafeExposure(uv);
        goldenHour = goldenHourValue;
        daytime = daytimeValue;
        _loading = false;
      });
    } catch (e) {
      print('UV API ERROR: $e');
      setState(() {
        _error = 'Failed to fetch UV index';
        _loading = false;
      });
    }
  }



  String _getRecommendedSPF(double uv) {
    if (uv >= 8) return 'SPF 50+';
    if (uv >= 6) return 'SPF 30+';
    if (uv >= 3) return 'SPF 15+';
    return 'Optional';
  }

  String _getSafeExposure(double uv) {
    if (uv >= 11) return '10-15 mins';
    if (uv >= 8) return '20 mins';
    if (uv >= 6) return '30 mins';
    if (uv >= 3) return '45 mins';
    return '60+ mins';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 343,
      height: 310,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xffC0F698).withOpacity(0.37),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Current UV index',
            style: GoogleFonts.montserrat(
                fontSize: 20, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1),
          Text(
            'Based on your skin characteristics and your current location',
            style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 17),
          GestureDetector(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('uv_enabled', true);
              _fetchUVIndex();
            },
            child: DottedBorder(
              color: Colors.black,
              strokeWidth: 1.4,
              dashPattern: [3, 3],
              borderType: BorderType.RRect,
              radius: Radius.circular(18),
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 288,
                  height: 185,
                  color: Colors.white,
                  padding: EdgeInsets.all(8),
                  child: _uvIndex == null && _loading == true
                      ? Center(child: Text('Tap to enable UV index'))
                      : _loading
                      ? Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(child: Text(_error!))
                      : Row(
                  children: [
                      CircleWidget(score: _uvIndex ?? 0),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset('assets/images/svg/recommended.svg'),                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Recommended', style: GoogleFonts.poppins(
                                      fontSize: 10, fontWeight: FontWeight.w300)),
                                  Text(recommendedSPF ?? 'N/A',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.lightGreen2,
                                          fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 29),
                          Row(
                            children: [
                              SvgPicture.asset('assets/images/svg/safe.svg'),                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Safe exposure time',style: GoogleFonts.poppins(
                                      fontSize: 10, fontWeight: FontWeight.w300)),
                                  Text(exposureTime ?? 'N/A',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.lightGreen2,
                                          fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 29),
                          Row(
                            children: [
                              SvgPicture.asset('assets/images/svg/golden.svg'),                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Golden hour', style: GoogleFonts.poppins(
                                      fontSize: 10, fontWeight: FontWeight.w300)),
                                  Text(goldenHour ?? 'N/A',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.lightGreen2,
                                          fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
