import 'package:Glowzel/module/treatment/pages/steps_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/security/secure_auth_storage.dart';
import '../../../core/storage_services/storage_service.dart';
import '../../../ui/button/custom_elevated_button.dart';
import '../../../ui/widget/nav_router.dart';
import '../../authentication/repository/auth_repository.dart';
import '../../authentication/repository/session_repository.dart';
import '../../scan/model/skin_analysis_response.dart';
import '../../user/repository/user_account_repository.dart';
enum ActiveSheet { overview, treatment }
ActiveSheet activeSheet = ActiveSheet.overview;
class VitaminBoostMaskPage extends StatefulWidget {
  const VitaminBoostMaskPage({super.key});

  @override
  State<VitaminBoostMaskPage> createState() => _VitaminBoostMaskPageState();
}

class _VitaminBoostMaskPageState extends State<VitaminBoostMaskPage> {
  bool isRated = false;
  bool showTreatment = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 311,
                child: Image.asset(
                  'assets/images/png/girl3.png',colorBlendMode: BlendMode.darken,
                  color: Colors.black.withOpacity(0.3),
                  fit: BoxFit.cover,
                ),
              ),

              // Top Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => NavRouter.pop(context),
                      icon: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: SvgPicture.asset('assets/images/svg/arrow.svg'),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Vitamin Boost Mask',
                      style: GoogleFonts.lato(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          width: 79,
                          height: 23,
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.black.withOpacity(0.35),
                          ),
                          child: Text('Moisturizing',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 5),
                        Container(
                          width: 79,
                          height: 23,
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.black.withOpacity(0.35),
                          ),
                          child: Text('For Oily-skin',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 5),
                        Container(
                          width: 90,
                          height: 23,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.black.withOpacity(0.35),
                          ),
                          child: Center(
                            child: Text('Acne Treatment',
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 44),
                    SizedBox(
                      height: 45,
                      width: 130,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: CircleAvatar(
                              radius: 22.5,
                              backgroundImage: AssetImage('assets/images/png/w1.png'),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            child: CircleAvatar(
                              radius: 22.5,
                              backgroundImage: AssetImage('assets/images/png/w2.png'),
                            ),
                          ),
                          Positioned(
                            left: 36,
                            child: CircleAvatar(
                              radius: 22.5,
                              backgroundImage: AssetImage('assets/images/png/w3.png'),
                            ),
                          ),
                          Positioned(
                            left: 54,
                            child: CircleAvatar(
                              radius: 22.5,
                              backgroundImage: AssetImage('assets/images/png/w4.png'),
                            ),
                          ),
                          Positioned(
                            left: 76,
                            child: CircleAvatar(
                              radius: 22.5,
                              backgroundImage: AssetImage('assets/images/png/w5.png'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 0),
                    Text(
                      '500 usd this week',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child:  showTreatment
                    ? TreatmentBottomSheet(
                  checkedList: [false, false, false, false],
                )
                    : Container(
                  height: 510,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isRated = !isRated;
                                });
                              },
                              child: Icon(
                                isRated ? Icons.star : Icons.star_border,
                                color: isRated ? Colors.amber : Colors.black,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 4),
                             Text(
                              '4.8',
                              style: GoogleFonts.inter(
                                  fontSize: 10, fontWeight: FontWeight.w400, color: Colors.black),
                            ),
                            const SizedBox(width: 10),
                            SvgPicture.asset('assets/images/svg/timer.svg', color: Colors.black),
                            const SizedBox(width: 4),
                             Text(
                              '15 min',
                              style: GoogleFonts.montserrat(
                                  fontSize: 10, fontWeight: FontWeight.w400, color: Colors.black),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                         Text(
                          'Overview',
                          style: GoogleFonts.montserrat(
                              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                         Text(
                           'Cleansing in the morning is essential to remove any\nsweat, excess oils, and impurities that have built up on\nyour skin overnight. it help to refresh your skin,unclog\npores, and prepare it for the absorption of subsequent\nskincare products.',
                           style: GoogleFonts.poppins(
                               fontSize: 10, fontWeight: FontWeight.w400, color: Colors.black),
                        ),
                        const SizedBox(height: 55),
                         Text(
                          'Ingredients',
                          style: GoogleFonts.montserrat(
                              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildIngredientItem(
                              imagePath: 'assets/images/png/banana.png',
                              name: 'Banana',
                              quantity: '1 piece',
                            ),
                            const SizedBox(width: 16),
                            _buildIngredientItem(
                              imagePath: 'assets/images/png/honey.png',
                              name: 'Honey',
                              quantity: '1 tbsp',
                            ),
                            const SizedBox(width: 16),
                            _buildIngredientItem(
                              imagePath: 'assets/images/png/lemon.png',
                              name: 'Lemon',
                              quantity: '1 tbsp',
                            ),
                          ],
                        ),
                        const SizedBox(height: 52),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left:37,right:37,bottom: 20),
                            child: CustomElevatedButton(
                              text: 'START TREATMENTS',
                              prefixIcon: SvgPicture.asset('assets/images/svg/timer1.svg'),
                              onPressed: () {
                                setState(() {
                                  showTreatment = true;
                                });
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) {
                                    return TreatmentBottomSheet(
                                      checkedList: [false, false, false, false], // initial states
                                    );
                                  }
                                ).whenComplete(() {
                                  setState(() {
                                    showTreatment = false;
                                  });
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
  }
}
Widget _buildIngredientItem({
  required String imagePath,
  required String name,
  required String quantity,
}) {
  return Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          imagePath,
          width: 59,
          height: 59,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        name,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        quantity,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w300,
          color: Colors.black,
        ),
      ),
    ],
  );
}
