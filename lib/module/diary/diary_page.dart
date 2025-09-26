import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:Glowzel/module/Home/widget/calendar_widget.dart';
import 'package:Glowzel/module/Home/widget/date_widget.dart';
import 'package:Glowzel/module/diary/dialy_log_feeling.dart';
import 'package:Glowzel/module/diary/edit_step_page.dart';
import 'package:Glowzel/module/diary/evening_routine_page.dart';
import 'package:Glowzel/module/diary/morning_routine_page.dart';
import 'package:Glowzel/module/diary/personalized_routine.dart';
import 'package:Glowzel/module/diary/under_eye_mask_page.dart';
import 'package:Glowzel/ui/widget/nav_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constant/app_color.dart';
import '../../core/exceptions/api_error.dart';
import '../../core/network/dio_client.dart';
import '../../core/security/secure_auth_storage.dart';
import '../../core/storage_services/storage_service.dart';
import '../Home/pages/home_page.dart';
import '../authentication/model/auth_response.dart';
import '../authentication/repository/auth_repository.dart';
import '../authentication/repository/session_repository.dart';
import '../scan/model/skin_analysis_response.dart';
import '../user/models/user_model.dart';
import '../user/repository/user_account_repository.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({Key? key}) : super(key: key);

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  List<int> selectedIndices = [];
  late StorageService storageService;
  late AuthRepository authRepository;
  late SessionRepository sessionRepository;
  late Future<UserModel?> userFuture;

  List<Map<String, dynamic>> amSteps = [];
  List<Map<String, dynamic>> pmSteps = [];
  List<Map<String, dynamic>> _skinLogs = [];
  bool _loading = true;
  String? _error;

  DateTime selectedDate = DateTime.now();
  List<bool> routineToggles = [
    true,
    false,
    true,
    true,
    false,
    false,
    false,
    false,
    false,
  ];

  List<Map<String, dynamic>> _skinHistory = [];

  @override
  void initState() {
    super.initState();
    sessionRepository = SessionRepository(
      storageService: GetIt.I<StorageService>(),
      authSecuredStorage: GetIt.I<AuthSecuredStorage>(),
    );
    authRepository = AuthRepository(
      dioClient: GetIt.I<DioClient>(),
      authSecuredStorage: GetIt.I<AuthSecuredStorage>(),
      userAccountRepository: GetIt.I<UserAccountRepository>(),
      sessionRepository: GetIt.I<SessionRepository>(),
    );
    userFuture = fetchUserData();

    fetchSkinHistory();
    loadRoutineToggles();
  }

  Future<UserModel?> fetchUserData() async {
    try {
      String? token = await sessionRepository.getToken();
      if (token != null) {
        return await authRepository.getMe();
      } else {
        throw Exception("Token not found");
      }
    } catch (e, stackTrace) {
      log("Error fetching user data: $e\n$stackTrace");
      return null;
    }
  }

  Future<void> fetchSkinHistory() async {
    try {
      final userId = await sessionRepository.getId();
      if (userId == null) throw Exception("User ID is null");

      final response = await GetIt.I<DioClient>().get(
        '/api/skin-analysis/user/$userId/history',
        queryParameters: {"limit": 50, "skip": 0},
      );

      if (response.statusCode == 200) {
        final jsonData =
            response.data is String ? jsonDecode(response.data) : response.data;
        final analyses = List<Map<String, dynamic>>.from(
          jsonData['data']['analyses'],
        );

        setState(() {
          _skinHistory = analyses;
        });

        updateRoutineForDate(selectedDate);
      }
    } catch (e) {
      debugPrint("❌ Error fetching history: $e");
    }
  }

  Future<void> fetchLogHistory() async {
    try {
      final logs = await authRepository.fetchDailyLogHistory();

      setState(() {
        _skinLogs = logs;
        _loading = false;
      });

      print('✅ Total logs fetched: ${logs.length}');
      if (logs.isNotEmpty) {
        // save latest log id
        final logId = logs.last['id'].toString();
        await sessionRepository.setLogId(logId);
        print('Saved log ID: $logId');

        final savedLogId = await sessionRepository.getLogId();
        print('Retrieved log ID from storage: $savedLogId');
      } else {
        print('⚠️ No logs returned from API');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      print('❌ Error fetching skin history: $e');
    }
  }

  void updateRoutineForDate(DateTime date) {
    if (_skinHistory.isEmpty) return;

    final formattedDate = DateFormat("yyyy-MM-dd").format(date);

    final match = _skinHistory.firstWhere(
      (analysis) {
        final analysisDate = DateFormat("yyyy-MM-dd")
            .format(DateTime.parse(analysis['analysisDate']));
        return analysisDate == formattedDate;
      },
      orElse: () => {},
    );

    final match1 = _skinLogs.firstWhere(
      (analysis) {
        final analysisDate = DateFormat("yyyy-MM-dd")
            .format(DateTime.parse(analysis['log_date']));
        return analysisDate == formattedDate;
      },
      orElse: () => {},
    );

    if (match.isNotEmpty) {
      final am = (match['amRoutine']?['steps'] as List? ?? [])
          .map<Map<String, dynamic>>((step) => {
                'title': '${step['step_number']}. ${step['product_type']}',
                'description': step['description'] ?? '',
              })
          .toList();

      final pm = (match['pmRoutine']?['steps'] as List? ?? [])
          .map<Map<String, dynamic>>((step) => {
                'title': '${step['step_number']}. ${step['product_type']}',
                'description': step['description'] ?? '',
              })
          .toList();

      setState(() {
        amSteps = am;
        pmSteps = pm;
      });
    } else {
      setState(() {
        amSteps = [];
        pmSteps = [];
      });
    }
  }

  void loadRoutineToggles() async {
    final saved = await sessionRepository.getToggle();
    if (saved != null) {
      setState(() {
        routineToggles = List<bool>.from(jsonDecode(saved));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData) {
          return const Center(child: Text("No User Data Found"));
        }
        final user = snapshot.data!;
        return Scaffold(
          backgroundColor: AppColors.grey3,
          body: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 10, left: 16, right: 16, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          backgroundImage:
                              user.image != null && user.image!.isNotEmpty
                                  ? (user.image!.startsWith("http")
                                      ? NetworkImage(user.image!)
                                      : MemoryImage(base64Decode(user.image!))
                                          as ImageProvider)
                                  : const AssetImage(
                                      "assets/images/png/women4.png"),
                        ),
                        const SizedBox(width: 9),
                        Text("Good day!",
                            style: GoogleFonts.lato(
                                color: AppColors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w600)),
                        const Spacer(),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    dialogBackgroundColor: Colors.white,
                                    colorScheme: ColorScheme.light(
                                      primary: AppColors.lightGreen2,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.lightGreen2,
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() => selectedDate = picked);
                              updateRoutineForDate(picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            height: 29,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                    'assets/images/svg/calendar.svg',
                                    fit: BoxFit.scaleDown),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat("MMMM yyyy").format(selectedDate),
                                  style: GoogleFonts.poppins(fontSize: 11),
                                ),
                                SizedBox(width: 4),
                                SvgPicture.asset(
                                    'assets/images/svg/arrow4.svg'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    CalendarWidget(
                      selectedDate: selectedDate,
                      onDateSelected: (date) {
                        setState(() => selectedDate = date);
                        updateRoutineForDate(date);
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 360,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text("Your daily routine",
                                          style: GoogleFonts.montserrat(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                      SizedBox(width: 68),
                      GestureDetector(
                        onTap: () async {
                          final updatedToggles = await showModalBottomSheet<List<bool>>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return EditRoutinePage(
                                initialToggles: routineToggles,
                              );
                            },
                          );

                          if (updatedToggles != null) {
                            setState(() {
                              routineToggles = updatedToggles;
                            });
                          }
                        },
                        child: Container(
                          width: 84,
                          height: 19,
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xffE3E9D0),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Edit routines",
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(width: 6),
                              SvgPicture.asset('assets/images/svg/arrow2.svg'),
                            ],
                          ),
                        ),
                      ),
                      ],
                                  ),
                                  Text("Tap on a routine to complete",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w300)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (routineToggles[0]) ...[
                            buildRoutineItem(
                              0,
                              'Morning routine',
                              '${amSteps.length} products',
                              'assets/images/svg/morning.svg',
                              onTapNavigate: () {
                                NavRouter.push(
                                    context,
                                    MorningRoutinePage(
                                        selectedDate: selectedDate));
                              },
                            ),
                            SizedBox(height: 18),
                          ],
                          if (routineToggles[1]) ...[
                            buildRoutineItem(
                              1,
                              'Afternoon Routine',
                              '8 products',
                              'assets/images/svg/afternoon.svg',
                              isBlack: true,
                              outerColor: Color(0xff4779C3),
                              onTapNavigate: () {},
                            ),
                            SizedBox(height: 18),
                          ],
                          if (routineToggles[2]) ...[
                            buildRoutineItem(
                              2,
                              'Skin daily log',
                              'How are you feeling today?',
                              'assets/images/svg/scan3.svg',
                              onTapNavigate: () {
                                NavRouter.push(
                                    context,
                                    DailyLogFeelingScreen(
                                        selectedDate: selectedDate));
                              },
                            ),
                            SizedBox(height: 18),
                          ],
                          if (routineToggles[3]) ...[
                            buildRoutineItem(
                              3,
                              'Evening routine',
                              '${pmSteps.length} products',
                              'assets/images/svg/moon.svg',
                              isBlack: true,
                              onTapNavigate: () {
                                NavRouter.push(
                                    context,
                                    EveningRoutinePage(
                                        selectedDate: selectedDate));
                              },
                            ),
                            SizedBox(height: 18),
                          ],
                          if (routineToggles[4]) ...[
                            buildRoutineItem(
                              4,
                              'Night routine',
                              '8 products',
                              'assets/images/svg/night.svg',
                              isBlack: true,
                              onTapNavigate: () {},
                            ),
                            SizedBox(height: 18),
                          ],
                          if (routineToggles[5]) ...[
                            buildRoutineItem(
                              5,
                              'Face exfoliation',
                              'Every 10 days',
                              'assets/images/svg/face.svg',
                              backgroundGradient: LinearGradient(colors: [
                                Color(0xffE2F5FF),
                                Color(0xff7FC4E9),
                              ]),
                              onTapNavigate: () {},
                            ),
                            SizedBox(height: 18),
                          ],
                          if (routineToggles[6]) ...[
                            buildRoutineItem(
                              6,
                              'Body exfoliation',
                              'Every Sunday',
                              'assets/images/svg/body.svg',
                              backgroundGradient: LinearGradient(colors: [
                                Color(0xffFFF0FA),
                                Color(0xff3F2938),
                              ]),
                              onTapNavigate: () {},
                            ),
                            SizedBox(height: 18),
                          ],
                          if (routineToggles[7]) ...[
                            buildRoutineItem(
                              7,
                              'Face mask',
                              'Daily',
                              'assets/images/svg/mask.svg',
                              backgroundColor: Color(0xffFFF0FA),
                              onTapNavigate: () {},
                            ),
                            SizedBox(height: 18),
                          ],
                          if (routineToggles[8]) ...[
                            buildRoutineItem(
                              4,
                              'Under eye mask',
                              'Daily',
                              'assets/images/svg/mask1.svg',
                              backgroundColor: Color(0xff00A8B5),
                              onTapNavigate: () {
                                NavRouter.push(context, UnderEyeMaskPage());
                              },
                            ),
                            SizedBox(height: 18),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildRoutineItem(
    int index,
    String title,
    String subtitle,
    String imagePath, {
    bool isBlack = false,
    VoidCallback? onTapNavigate,
    Color backgroundColor = const Color(0xffFFF0FA),
    Gradient? backgroundGradient,
    Color outerColor = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTapNavigate,
      child: Container(
        width: 326,
        height: 78,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xffD9D9D9), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: backgroundGradient == null
                    ? backgroundColor ?? const Color(0xffFFF0FA)
                    : null,
                gradient: backgroundGradient,
                shape: BoxShape.circle,
              ),
              child: isBlack
                  ? Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: outerColor,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                          child: Center(child: SvgPicture.asset(imagePath))),
                    )
                  : ClipOval(child: Center(child: SvgPicture.asset(imagePath))),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w300),
                ),
              ],
            ),
            Spacer(),
            SvgPicture.asset('assets/images/svg/arrow5.svg'),
          ],
        ),
      ),
    );
  }
}
