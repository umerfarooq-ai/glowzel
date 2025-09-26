import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:Glowzel/core/di/service_locator.dart';
import 'package:Glowzel/module/Home/widget/date_widget.dart';
import 'package:Glowzel/module/diary/cubit/daily_log_cubit.dart';
import 'package:Glowzel/module/diary/cubit/daily_log_state.dart';
import 'package:Glowzel/module/diary/model/daily_log_input.dart';
import 'package:Glowzel/module/diary/model/daily_skin_log_model.dart';
import 'package:Glowzel/module/diary/model/update_diary_input.dart';

import 'package:Glowzel/module/diary/widgets/date_widget1.dart';
import 'package:Glowzel/module/diary/widgets/greeting_widget.dart';
import 'package:Glowzel/module/diary/widgets/routine_item_widget.dart';
import 'package:Glowzel/module/diary/widgets/slider_widget.dart';
import 'package:Glowzel/module/user/cubit/user_cubit.dart';
import 'package:Glowzel/ui/button/custom_elevated_button.dart';
import 'package:Glowzel/ui/widget/custom_app_bar.dart';
import 'package:Glowzel/ui/widget/custom_app_bar1.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../Constant/app_color.dart';
import '../../core/exceptions/api_error.dart';
import '../../core/network/dio_client.dart';
import '../../core/security/secure_auth_storage.dart';
import '../../core/storage_services/storage_service.dart';
import '../../ui/widget/nav_router.dart';
import '../Home/widget/daily_log_slider.dart';
import '../authentication/repository/auth_repository.dart';
import '../authentication/repository/session_repository.dart';
import '../user/models/user_model.dart';
import '../user/repository/user_account_repository.dart';


class DailyLogFeelingScreen extends StatelessWidget {
  final DateTime selectedDate;
  const DailyLogFeelingScreen({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DailySkinLogCubit(authRepository: sl()),
      child:DailyLogFeelingScreenView(selectedDate: selectedDate),
    );
  }
}

class DailyLogFeelingScreenView extends StatefulWidget {
  final DateTime selectedDate;
  const DailyLogFeelingScreenView({super.key, required this.selectedDate});

  @override
  State<DailyLogFeelingScreenView> createState() => _DailyLogFeelingScreenViewState();
}

class _DailyLogFeelingScreenViewState extends State<DailyLogFeelingScreenView> {
  int? selectedSkinIndex;
  int? selectedSleepIndex;
  Set<int> selectedIndices = {};
  late StorageService storageService;
  late AuthRepository authRepository;
  late SessionRepository sessionRepository;
  late Future<UserModel?> userFuture;
  final bool isSelected=false;
  double skinFeelingValue = 2.0;
  double waterIntakeValue = 2.0;
  List<Map<String, dynamic>> _skinLogs = [];
  bool _loading = true;
  String? _error;
  final Map<String, String> _initialValues = {};


  @override
  void initState() {
    super.initState();
    sessionRepository = SessionRepository(
        storageService: GetIt.I<StorageService>(),
        authSecuredStorage: GetIt.I<AuthSecuredStorage>());
    authRepository = AuthRepository(
      dioClient: GetIt.I<DioClient>(),
      authSecuredStorage: GetIt.I<AuthSecuredStorage>(),
      userAccountRepository: GetIt.I<UserAccountRepository>(),
      sessionRepository: GetIt.I<SessionRepository>(),
    );
    userFuture = fetchUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchLogHistory();
    });
  }

  Future<UserModel?> fetchUserData() async {
    try {
      String? token = await sessionRepository.getToken();

      if (token != null) {
        UserModel user = await authRepository.getMe();
        return user;
      } else {
        throw ApiError(message: 'Token not found');
      }
    } catch (e, stackTrace) {
      log('Error fetching user data: $e\nStackTrace: $stackTrace');
      return null;
    }
  }

  Future<void> fetchLogHistory() async {
    try {
      final logs = await authRepository.fetchDailyLogHistory();

      final selectedDateString = widget.selectedDate.toIso8601String().split('T').first;
      final logForDate = logs.firstWhere(
            (log) => log['log_date'] != null &&
            log['log_date'].toString().split('T').first == selectedDateString,
        orElse: () => {},
      );

      setState(() {
        _skinLogs = logs;
        _loading = false;

        if (logForDate.isNotEmpty) {
          final skinTypes = ['Normal', 'Oily', 'Dehydrated', 'Itchy'];
          selectedSkinIndex = skinTypes.indexOf(logForDate['skin_description'] ?? '');

          final sleepHoursList = ['0-3', '3-6', '6-9', '9+'];
          selectedSleepIndex = sleepHoursList.indexOf(logForDate['sleep_hours'] ?? '');

          selectedIndices.clear();
          final dietList = [
            'Dairy', 'Seafood', 'Meat', 'Poultry',
            'Snacks', 'Fast food', 'Fruits', 'Vegetables',
            'Pastry', 'Grains,Brans & Nuts', 'Caffeine', 'Alcohol'
          ];
          if (logForDate['diet_items'] != null) {
            final items = logForDate['diet_items'].toString().split(',');
            for (var item in items) {
              final index = dietList.indexOf(item.trim());
              if (index != -1) selectedIndices.add(index);
            }
          }

          skinFeelingValue = double.tryParse(logForDate['skin_feel']!.toString())!;
          waterIntakeValue = double.tryParse(logForDate['water_intake']!.toString())!;
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      print('❌ Error fetching skin history: $e');
    }
  }

  Future<void> _updateDailyLog() async {
    if (_skinLogs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No log found to update")),
      );
      return;
    }

    // Get the log ID for the selected date
    final selectedDateString = widget.selectedDate.toIso8601String().split('T').first;
    final logForDate = _skinLogs.firstWhere(
          (log) => log['log_date'] != null &&
          log['log_date'].toString().split('T').first == selectedDateString,
      orElse: () => {},
    );

    if (logForDate == null || logForDate['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No log found to update")),
      );
      return;
    }

    final int logId = logForDate['id'];

    // Prepare the input
    final skinTypes = ['Normal', 'Oily', 'Dehydrated', 'Itchy'];
    final sleepHoursList = ['0-3', '3-6', '6-9', '9+'];
    final dietList = [
      'Dairy', 'Seafood', 'Meat', 'Poultry',
      'Snacks', 'Fast food', 'Fruits', 'Vegetables',
      'Pastry', 'Grains,Brans & Nuts', 'Caffeine', 'Alcohol'
    ];

    final updatedFields = {
      'skin_feel': skinFeelingValue.toString(),
      'skin_description': selectedSkinIndex != null ? skinTypes[selectedSkinIndex!] : '',
      'sleep_hours': selectedSleepIndex != null ? sleepHoursList[selectedSleepIndex!] : '',
      'diet_items': selectedIndices.map((i) => dietList[i]).join(','),
      'water_intake': waterIntakeValue.toString(),
    };

    try {
      final updatedLog = await authRepository.updateDailySkinLog(
        logId: logId,
        input: updatedFields,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Daily log updated successfully")),
      );

      // Optionally refresh log history
      await fetchLogHistory();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update log: $e")),
      );
      print("❌ Error updating daily log: $e");
    }
  }





  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        else if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Text(
              snapshot.hasError
                  ? "Failed to fetch user data"
                  : "No User Data Found",
              style: GoogleFonts.poppins(
                  color: Colors.white),
            ),
          );
        }
        final user = snapshot.data!;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.grey3,
          appBar: CustomAppBar1(user: user,showBackButton: true,showFrontButton: true,text:DateFormat('d MMM yyy').format(widget.selectedDate),),
          body: Padding(
            padding: const EdgeInsets.only(top: 60,left: 31,right: 33,bottom: 40),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('How does your skin feel today?',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: 30),
                  SliderWidget(
                    value: skinFeelingValue,
                    onChanged: (value) {
                      setState(() {
                        skinFeelingValue = value;
                      });
                    },
                  ),
                  SizedBox(height: 24),
                  Text('How would you describe your skin?',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(child: RoutineItemWidget(
                        title: 'Normal', imagePath:  'assets/images/svg/normal2.svg',
                        isSelected:selectedSkinIndex == 0,
                        onTap: () {
                          setState(() {
                            selectedSkinIndex = 0;
                          });
                        },
                      )),
                      SizedBox(width: 10),
                      Expanded(child: RoutineItemWidget(
                        title: 'Oily', imagePath: 'assets/images/svg/oily2.svg',
                        isSelected: selectedSkinIndex == 1,
                        onTap: () {
                          setState(() {
                            selectedSkinIndex = 1;
                          });
                        },
                      )),
                      SizedBox(width: 10),
                      Expanded(child: RoutineItemWidget(
                        title: 'Degydrated', imagePath: 'assets/images/svg/dehy.svg',
                        isSelected: selectedSkinIndex == 2,
                        onTap: () {
                          setState(() {
                            selectedSkinIndex = 2;
                          });
                        },
                      )),
                      SizedBox(width: 10),
                      Expanded(child: RoutineItemWidget(
                        title: 'Itchy', imagePath: 'assets/images/svg/ichy.svg',
                        isSelected: selectedSkinIndex == 3,
                        onTap: () {
                          setState(() {
                            selectedSkinIndex = 3;
                          });
                        },
                      )),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text('Sleep',
                    style: GoogleFonts.montserrat(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text('How many hours did your sleep?',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: RoutineItemWidget(
                            title: '0-3 hours',
                            imagePath: 'assets/images/svg/black_circle.svg',
                            isSelected:selectedSleepIndex==0,
                            onTap: (){
                              setState(() {
                                selectedSleepIndex=0;
                              });
                            }
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                selectedSleepIndex=1;
                              });
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: selectedSleepIndex==1?Color(0xffDBEAAC):Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                    color: Colors.black12,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    left: 16,
                                      child: SvgPicture.asset('assets/images/svg/orange_circle.svg')),
                                  Positioned(
                                      left: 12,
                                      child: SvgPicture.asset('assets/images/svg/black_circle.svg')),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '3-6 hours',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                selectedSleepIndex=2;
                              });
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: selectedSleepIndex==2?Color(0xffDBEAAC):Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                    color: Colors.black12,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    left: 24,
                                      child: SvgPicture.asset('assets/images/svg/orange_circle.svg')),
                                  Positioned(
                                      left: 6,
                                      child: SvgPicture.asset('assets/images/svg/black_circle.svg')),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '6-9 hours',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: RoutineItemWidget(
                            title: '9+ hours',
                            imagePath: 'assets/images/svg/black_circle.svg',
                            isSelected:selectedSleepIndex==3,
                            onTap: (){
                              setState(() {
                                selectedSleepIndex=3;
                              });
                            }
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Diet',
                    style: GoogleFonts.montserrat(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text('What did you eat/drink today?',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 41),
                  Row(
                    children: [
                      Expanded(
                        child: RoutineItemWidget(
                            title: 'Dairy',
                            imagePath: 'assets/images/svg/diary2.svg',
                            isSelected: selectedIndices.contains(0),
                            onTap: (){
                              setState(() {
                                if (selectedIndices.contains(0)) {
                                  selectedIndices.remove(0);
                                } else {
                                  selectedIndices.add(0);
                                }
                              });
                            }
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: RoutineItemWidget(
                            title: 'Seafood',
                            imagePath: 'assets/images/svg/fish.svg',
                            isSelected: selectedIndices.contains(1),
                            onTap: (){
                              setState(() {
                                if (selectedIndices.contains(1)) {
                                  selectedIndices.remove(1);
                                } else {
                                  selectedIndices.add(1);
                                }
                              });
                            }
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: RoutineItemWidget(
                            title: 'Meat',
                            imagePath: 'assets/images/svg/meat.svg',
                            isSelected: selectedIndices.contains(2),
                            onTap: (){
                              setState(() {
                                if (selectedIndices.contains(2)) {
                                  selectedIndices.remove(2);
                                } else {
                                  selectedIndices.add(2);
                                }
                              });
                            }
                        ),
                      ),
                      SizedBox(width:10),
                      Expanded(
                        child: RoutineItemWidget(
                            title: 'Poultry',
                            imagePath: 'assets/images/svg/poultry.svg',
                            isSelected: selectedIndices.contains(3),
                            onTap: (){
                              setState(() {
                                if (selectedIndices.contains(3)) {
                                  selectedIndices.remove(3);
                                } else {
                                  selectedIndices.add(3);
                                }
                              });
                            }
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: RoutineItemWidget(
                            title: 'Snacks',
                            imagePath: 'assets/images/svg/snack.svg',
                            isSelected: selectedIndices.contains(4),
                            onTap: (){
                              setState(() {
                                if (selectedIndices.contains(4)) {
                                  selectedIndices.remove(4);
                                } else {
                                  selectedIndices.add(4);
                                }
                              });
                            }
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: RoutineItemWidget(
                            title: 'Fast food',
                            imagePath: 'assets/images/svg/fast.svg',
                            isSelected: selectedIndices.contains(5),
                            onTap: (){
                              setState(() {
                                if (selectedIndices.contains(5)) {
                                  selectedIndices.remove(5);
                                } else {
                                  selectedIndices.add(5);
                                }
                              });
                            }
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: RoutineItemWidget(
                            title: 'Fruits',
                            imagePath: 'assets/images/svg/fruits.svg',
                            isSelected: selectedIndices.contains(6),
                            onTap: (){
                              setState(() {
                                if (selectedIndices.contains(6)) {
                                  selectedIndices.remove(6);
                                } else {
                                  selectedIndices.add(6);
                                }
                              });
                            }
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: RoutineItemWidget(
                            title: 'Vegetables',
                            imagePath: 'assets/images/svg/vegetables.svg',
                            isSelected: selectedIndices.contains(7),
                            onTap: (){
                              setState(() {
                                if (selectedIndices.contains(7)) {
                                  selectedIndices.remove(7);
                                } else {
                                  selectedIndices.add(7);
                                }
                              });
                            }
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: RoutineItemWidget(
                            title: 'Pastry',
                            imagePath: 'assets/images/svg/pastry.svg',
                            isSelected: selectedIndices.contains(8),
                            onTap: (){
                              setState(() {
                                if (selectedIndices.contains(8)) {
                                  selectedIndices.remove(8);
                                } else {
                                  selectedIndices.add(8);
                                }
                              });
                            }
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: RoutineItemWidget(
                            title: 'Grains,Brans & Nuts',
                            imagePath: 'assets/images/svg/grains.svg',
                            isSelected: selectedIndices.contains(9),
                            onTap: (){
                              setState(() {
                                if (selectedIndices.contains(9)) {
                                  selectedIndices.remove(9);
                                } else {
                                  selectedIndices.add(9);
                                }
                              });
                            }
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: RoutineItemWidget(
                            title: 'Caffeine',
                            imagePath: 'assets/images/svg/caffeine.svg',
                            isSelected: selectedIndices.contains(10),
                            onTap: (){
                              setState(() {
                                if (selectedIndices.contains(10)) {
                                  selectedIndices.remove(10);
                                } else {
                                  selectedIndices.add(10);
                                }
                              });
                            }
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: RoutineItemWidget(
                            title: 'Alcohol',
                            imagePath: 'assets/images/svg/alcohol.svg',
                            isSelected: selectedIndices.contains(11),
                            onTap: (){
                              setState(() {
                                if (selectedIndices.contains(11)) {
                                  selectedIndices.remove(11);
                                } else {
                                  selectedIndices.add(11);
                                }
                              });
                            }
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 35),
                  Text('How much water did you take?',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  DailyLogSlider(
                    value:waterIntakeValue,
                    onChanged: (value) {
                      setState(() {
                        waterIntakeValue = value;
                      });
                    },
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(left:37,right:37,bottom: 20),
            child:Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomElevatedButton(
                  text: 'ADD',
                  onPressed: () async {
                    if (selectedSkinIndex == null || selectedSleepIndex == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please select skin type and sleep hours"))
                      );
                      return;
                    }

                    final skinTypes = ['Normal', 'Oily', 'Dehydrated', 'Itchy'];
                    final sleepHoursList = ['0-3', '3-6', '6-9', '9+'];
                    final dietList = [
                      'Dairy', 'Seafood', 'Meat', 'Poultry',
                      'Snacks', 'Fast food', 'Fruits', 'Vegetables',
                      'Pastry', 'Grains,Brans & Nuts', 'Caffeine', 'Alcohol'
                    ];

                    final input = DailySkinLogInput(
                      skinFeel: (skinFeelingValue).toString(),
                      skinDescription: skinTypes[selectedSkinIndex!],
                      sleepHours: sleepHoursList[selectedSleepIndex!],
                      dietItems: selectedIndices.map((i) => dietList[i]).join(','),
                      waterIntake:(waterIntakeValue).toString(),
                    );

                    final cubit = context.read<DailySkinLogCubit>();
                    await cubit.createDailySkinLog(input);

                    final state = cubit.state;
                    if (state.dailySkinLogStatus == DailySkinLogStatus.success) {
                      NavRouter.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Daily log added successfully"))
                      );
                    } else if (state.dailySkinLogStatus == DailySkinLogStatus.error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.errorMessage ?? "Something went wrong"))
                      );
                    }
                  },
                ),
                IconButton(
                  onPressed: _updateDailyLog,
                  icon: Text(
                    'Update Daily Log',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w400,
                        color: AppColors.lightGreen2),
                  ),
                ),
              ],
            ),
          ),

        );
      },
    );
  }
}
