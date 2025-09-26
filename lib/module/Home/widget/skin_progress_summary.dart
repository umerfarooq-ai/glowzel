import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:Glowzel/module/authentication/repository/auth_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Constant/app_color.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/security/secure_auth_storage.dart';
import '../../authentication/repository/session_repository.dart';
import '../../user/repository/user_account_repository.dart';
import 'circle_widget.dart';

class SkinProgressSummary extends StatefulWidget {
  final String selectedDuration;

  const SkinProgressSummary({
    Key? key,
    required this.selectedDuration,
  }) : super(key: key);

  @override
  _SkinProgressSummaryState createState() => _SkinProgressSummaryState();
}

class _SkinProgressSummaryState extends State<SkinProgressSummary> {
  late Future<List<Map<String, dynamic>>> historyFuture;
  late AuthRepository authRepository;

  @override
  void initState() {
    super.initState();
    authRepository = AuthRepository(
      dioClient: GetIt.I<DioClient>(),
      authSecuredStorage: GetIt.I<AuthSecuredStorage>(),
      userAccountRepository: GetIt.I<UserAccountRepository>(),
      sessionRepository: GetIt.I<SessionRepository>(),
    );
    historyFuture = authRepository.fetchUserSkinHistory();
  }

  @override
  void didUpdateWidget(SkinProgressSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDuration != widget.selectedDuration) {
      setState(() {
        historyFuture = authRepository.fetchUserSkinHistory();
      });
    }
  }

  Map<String, double> calculateAverage(List<Map<String, dynamic>> records) {
    if (records.isEmpty) return {};

    final matrixKeys = ['elasticity','moisture', 'complexion', 'texture','acne','dryness'];

    Map<String, double> totals = {};
    for (var key in [...matrixKeys]) {
      totals[key] = 0.0;
    }

    for (var record in records) {
      final matrix = Map<String, dynamic>.from(record['skinHealthMatrix'] ?? {});

      for (var key in matrixKeys) {
        totals[key] = (totals[key] ?? 0.0) + (matrix[key]?.toDouble() ?? 0.0);
      }
    }

    for (var key in totals.keys) {
      totals[key] = double.parse((totals[key]! / records.length).toStringAsFixed(2));
    }

    return totals;
  }

  double calculateRiskScore(Map<String, double> data) {
    final riskFactors = ['blemishes', 'spots', 'oiliness', 'fineLines', 'redness'];
    final positiveFactors = ['hydration', 'elasticity', 'complexion', 'texture'];

    double totalPositive = 0;
    int positiveCount = 0;

    for (var key in positiveFactors) {
      if (data.containsKey(key)) {
        totalPositive += data[key]!;
        positiveCount++;
      }
    }

    double totalRisk = 0;
    int riskCount = 0;

    for (var key in riskFactors) {
      if (data.containsKey(key)&& data[key] != null) {
        totalRisk += data[key]!;
        riskCount++;
      }
    }

    final normalizedPositive = positiveCount > 0 ? (totalPositive / positiveCount) : 0;
    final normalizedRisk = riskCount > 0 ? (totalRisk / riskCount) : 0;

    final score = (normalizedPositive * 0.6) + ((100 - normalizedRisk) * 0.4);

    return score.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 343,
            height: 243,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            width: 343,
            height: 243,
            child: Center(child: Text("No data available")),
          );
        }

        final now = DateTime.now();
        final filtered = snapshot.data!.where((record) {
          final timestamp = DateTime.tryParse(record['analysisDate'] ?? '');
          if (timestamp == null) return false;
          switch (widget.selectedDuration) {
            case 'Daily':
              return timestamp.day == now.day &&
                  timestamp.month == now.month &&
                  timestamp.year == now.year;
            case 'Weekly':
              return now.difference(timestamp).inDays <= 7;
            case 'Monthly':
              return now.month == timestamp.month &&
                  now.year == timestamp.year;
            default:
              return false;
          }
        }).toList();

        final averages = calculateAverage(filtered);
        final riskScore = calculateRiskScore(averages);

        return Container(
          width: 343,
          height: 243,
          padding: EdgeInsets.only(left: 20, right: 20, top: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skin progress summary',
                style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Column(
                    children: [
                      CustomListTile(
                        imagePath: 'assets/images/png/moisture.png',
                        title: '${averages['moisture']?.toInt() ?? 0}%',
                        subtitle: 'Skin Moisture',
                      ),
                      SizedBox(height: 11),
                      CustomListTile(
                        imagePath: 'assets/images/png/cell.png',
                        title: '${averages['complexion']?.toInt() ?? 0}%',
                        subtitle: 'Cell Activity',
                      ),
                      SizedBox(height: 11),
                      CustomListTile(
                        imagePath: 'assets/images/png/wrinkle.png',
                        title: '${averages['texture']?.toInt() ?? 0}%',
                        subtitle: 'Skin Wrinkles',
                      ),
                    ],
                  ),
                  SizedBox(width: 17),
                  DottedBorder(
                    color: Colors.black,
                    strokeWidth: 1,
                    dashPattern: [5, 5],
                    borderType: BorderType.RRect,
                    radius: Radius.circular(18),
                    child: Container(
                      width: 150,
                      height: 169,
                      child: SkinCircleWidget(score: riskScore),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
class CustomListTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const CustomListTile({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 115,
      height: 49,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGreen3, width: 1),
        borderRadius: BorderRadius.circular(5),
        color: AppColors.lightGreen3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

// class CustomDropdown extends StatefulWidget {
//   final String initialValue;
//   final ValueChanged<String> onChanged;
//
//   const CustomDropdown({
//     Key? key,
//     required this.initialValue,
//     required this.onChanged,
//   }) : super(key: key);
//
//   @override
//   _CustomDropdownState createState() => _CustomDropdownState();
// }
//
// class _CustomDropdownState extends State<CustomDropdown> {
//   late String selectedValue;
//   List<String> options = ['Daily', 'Weekly', 'Monthly'];
//
//   @override
//   void initState() {
//     super.initState();
//     selectedValue = widget.initialValue;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DropdownButtonHideUnderline(
//       child: DropdownButton<String>(
//         value: selectedValue,
//         icon: Icon(
//           Icons.keyboard_arrow_down,
//           color: Colors.grey.shade600,
//           size: 14,
//         ),
//         style: const TextStyle(
//           color: Colors.black,
//           fontSize: 10,
//           fontWeight: FontWeight.w300,
//         ),
//         dropdownColor: Colors.white,
//         items: options.map<DropdownMenuItem<String>>((String value) {
//           return DropdownMenuItem<String>(
//             value: value,
//             child: Text(value),
//           );
//         }).toList(),
//         onChanged: (String? newValue) {
//           if (newValue != null) {
//             setState(() {
//               selectedValue = newValue;
//             });
//             widget.onChanged(newValue);
//           }
//         },
//       ),
//     );
//   }
// }