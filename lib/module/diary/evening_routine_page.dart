import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../Constant/app_color.dart';
import '../../core/network/dio_client.dart';
import '../../core/security/secure_auth_storage.dart';
import '../../core/storage_services/storage_service.dart';
import '../../ui/button/custom_elevated_button.dart';
import '../../ui/widget/nav_router.dart';
import '../authentication/repository/auth_repository.dart';
import '../authentication/repository/session_repository.dart';
import '../scan/model/skin_analysis_response.dart';
import '../user/repository/user_account_repository.dart';
import 'edit_step_evening_page.dart';
import 'edit_steps_page.dart';

class EveningRoutinePage extends StatefulWidget {
  final DateTime selectedDate;

  const EveningRoutinePage({super.key, required this.selectedDate});

  @override
  State<EveningRoutinePage> createState() => _EveningRoutinePageState();
}

class _EveningRoutinePageState extends State<EveningRoutinePage> {
  List<Map<String, dynamic>> allSteps = [];
  List<Map<String, dynamic>> visibleSteps = [];
  late SessionRepository sessionRepository;
  late AuthRepository authRepository;
  List<bool> stepsToggles = [];

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
      sessionRepository: sessionRepository,
    );

    loadSteps();
  }

  void loadSteps() async {
    final savedToggles =
        await sessionRepository.getEveningToggleForDate(widget.selectedDate);
    if (savedToggles != null) {
      stepsToggles = savedToggles;
    } else {
      stepsToggles = List.generate(allSteps.length, (_) => true);
    }

    final userId = await sessionRepository.getId();
    List<Map<String, dynamic>> apiSteps = [];

    if (userId != null) {
      final response = await GetIt.I<DioClient>().get(
        '/api/skin-analysis/user/$userId/history',
        queryParameters: {'limit': 50, 'skip': 0},
      );

      if (response.statusCode == 200) {
        final data =
            response.data is String ? jsonDecode(response.data) : response.data;
        final analyses =
            List<Map<String, dynamic>>.from(data['data']['analyses'] ?? []);

        if (analyses.isNotEmpty) {
          final String targetDate =
              DateFormat('yyyy-MM-dd').format(widget.selectedDate);

          final analysisForDate = analyses.firstWhere(
            (a) {
              final analysisDate = (a['analysisDate'] ?? '').toString();
              return analysisDate.startsWith(targetDate);
            },
            orElse: () => {},
          );

          if (analysisForDate.isNotEmpty) {
            final stepsData =
                analysisForDate['pmRoutine']?['steps'] as List<dynamic>? ?? [];
            apiSteps = stepsData
                .map((step) => {
                      'title': step['product_type'] ?? 'Step',
                      'description': step['description'] ?? '',
                      'isCustom': false,
                      'image': step['image'] ?? 'assets/images/png/p1.png',
                    })
                .toList();
          }
        }
      }
    }

    if (apiSteps.isEmpty) {
      apiSteps = List.generate(
          4,
          (i) => {
                'title': 'Step ${i + 1}',
                'description': 'Description for step ${i + 1}',
                'isCustom': false,
                'image': 'assets/images/png/p1.png',
              });
    }

    allSteps = [...apiSteps];
    if (stepsToggles.isEmpty) {
      stepsToggles = List.generate(allSteps.length, (_) => true);
    } else if (stepsToggles.length < allSteps.length) {
      stepsToggles.addAll(
          List.generate(allSteps.length - stepsToggles.length, (_) => true));
    }

    filterVisibleSteps();
  }

  void filterVisibleSteps() {
    visibleSteps = [];
    for (int i = 0; i < allSteps.length; i++) {
      if (stepsToggles[i]) {
        visibleSteps.add(allSteps[i]);
      }
    }
    setState(() {});
  }

  void saveToggles() async {
    await sessionRepository.setEveningToggleForDate(
        widget.selectedDate, stepsToggles);
    filterVisibleSteps();
  }

  void _showAddProductDialog() {
    String productName = '';
    String productDescription = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Add Your Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Product Name'),
                onChanged: (value) => productName = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => productDescription = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(
              width: 100,
              child: CustomElevatedButton(
                text: 'Add',
                onPressed: () {
                  setState(() {
                    allSteps.add({
                      'title': productName,
                      'description': productDescription,
                      'isCustom': true,
                      'image': 'assets/images/png/p1.png',
                    });
                    stepsToggles.add(true);
                    saveToggles();
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            SizedBox(
              width: double.infinity,
              height: 250,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 258,
                    child: Image.asset(
                      'assets/images/png/evening.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, 55),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('MMMM d EEEE')
                                .format(widget.selectedDate),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Evening Routine',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Cleanse, repair, and renew skin overnight.',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 55),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xffFFF0FA),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                  width: 29,
                                  height: 29,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: SvgPicture.asset(
                                      'assets/images/svg/moon.svg',
                                      fit: BoxFit.scaleDown)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Steps
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              Text('Steps',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(width: 183),
                              GestureDetector(
                                onTap: () async {
                                  final updatedToggles =
                                      await showModalBottomSheet<List<bool>>(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) {
                                            return EditStepsEveningPage(
                                                initialToggles:
                                                    stepsToggles,
                                                selectedDate:
                                                    widget.selectedDate);
                                          });
                                  if (updatedToggles != null) {
                                    setState(() {
                                      stepsToggles =
                                          List<bool>.from(updatedToggles);
                                      saveToggles();
                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    Text('Edit steps',
                                        style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w300)),
                                    const SizedBox(width: 5),
                                    SvgPicture.asset(
                                        'assets/images/svg/arrow2.svg'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text('${visibleSteps.length} products',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, fontWeight: FontWeight.w300)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: List.generate(visibleSteps.length, (index) {
                      final step = visibleSteps[index];
                      final originalIndex = allSteps.indexOf(step);
                      return Column(
                        children: [
                          CustomElevatedListTile(
                            title: step['title'] ?? '',
                            text: '${originalIndex + 1}',
                            detail: step['description'] ?? '',
                            isSelected: stepsToggles[originalIndex],
                            isCustom: step['isCustom'] == true,
                            onTap: () {
                              setState(() {
                                stepsToggles[originalIndex] =
                                    !stepsToggles[originalIndex];
                                saveToggles();
                              });
                            },
                            onAddProductTap: _showAddProductDialog,
                          ),
                          const SizedBox(height: 40),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 37, right: 37, bottom: 20),
        child: CustomElevatedButton(
          text: 'COMPLETE ROUTINE',
          onPressed: () async {
            final userId = await sessionRepository.getId();
            debugPrint('✅ Routine completed by user $userId');
            NavRouter.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Morning Routine Completed Successfully')),
            );
          },
        ),
      ),
    );
  }
}

class CustomElevatedListTile extends StatelessWidget {
  final String title;
  final String text;
  final String detail;
  final bool isSelected;
  final bool? isCustom;
  final VoidCallback? onTap;
  final VoidCallback? onAddProductTap;

  const CustomElevatedListTile({
    Key? key,
    required this.title,
    required this.text,
    required this.detail,
    required this.isSelected,
    this.isCustom,
    this.onTap,
    this.onAddProductTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        children: [
          Row(
            children: [
              Text(text,
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.w500)),
              const SizedBox(width: 10),
              SizedBox(
                width: 59,
                height: 59,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset('assets/images/png/sun_screen.png',
                      fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Text(title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onAddProductTap,
                    child: Container(
                      width: 130,
                      height: 21,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xffDBEAAC),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('+ Add your own product',
                          style: GoogleFonts.poppins(
                              fontSize: 10, fontWeight: FontWeight.w300),
                          textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(detail,
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }
}
