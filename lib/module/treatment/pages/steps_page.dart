import 'package:Glowzel/module/treatment/pages/start_treatment_page4.dart';
import 'package:Glowzel/module/treatment/widget/ingrident_item_widget.dart';
import 'package:Glowzel/ui/button/custom_elevated_button.dart';
import 'package:Glowzel/ui/widget/nav_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TreatmentBottomSheet extends StatefulWidget {
  final List<bool> checkedList;

  const TreatmentBottomSheet({super.key, required this.checkedList});

  @override
  State<TreatmentBottomSheet> createState() => _TreatmentBottomSheetState();
}

class _TreatmentBottomSheetState extends State<TreatmentBottomSheet> {
  bool isRated = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
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
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SvgPicture.asset(
                      'assets/images/svg/timer.svg',
                      color: Colors.black,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '15 min',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Text(
                  'Overview',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Cleansing in the morning is essential to remove any\nsweat, excess oils, and impurities that have built up on\nyour skin overnight. it help to refresh your skin, unclog\npores, and prepare it for the absorption of subsequent\nskincare products.',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 23),

                /// Ingredients
                Text(
                  'Ingredients',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildIngredient("Banana", "1 piece"),
                    const SizedBox(width: 22),
                    _buildIngredient("Honey", "1 tbsp"),
                    const SizedBox(width: 22),
                    _buildIngredient("Lemon juice", "1 tbsp"),
                  ],
                ),
                const SizedBox(height: 37),

                /// Steps (replace Steps widget with yours)
                _buildStep("Step1", "Collect Ingredients", 0),
                const SizedBox(height: 25),
                _buildStep("Step2", "Mix the ingredients together", 1),
                const SizedBox(height: 25),
                _buildStep("Step3", "Apply the mask", 2),
                const SizedBox(height: 25),
                _buildStep("Step4", "Let the mask sit", 3),

                const SizedBox(height: 54),

                /// Button
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 37, right: 37, bottom: 20),
                    child: CustomElevatedButton(
                      text: 'START',
                      onPressed: () {
                        NavRouter.push(context, StartTreatmentPage4());
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredient(String name, String qty) {
    return Column(
      children: [
        Text(
          name,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          qty,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildStep(String step, String subText, int index) {
    return Steps(
      text: step,
      subText: subText,
      isChecked: widget.checkedList[index],
      onChecked: (val) {
        setState(() {
          widget.checkedList[index] = val;
        });
      },
    );
  }
}
