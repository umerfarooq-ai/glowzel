import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../ui/button/custom_elevated_button.dart';
import '../../../ui/widget/nav_router.dart';

class VitaminBoostMaskPage2 extends StatefulWidget {
  const VitaminBoostMaskPage2({super.key});

  @override
  State<VitaminBoostMaskPage2> createState() => _VitaminBoostMaskPage2State();
}

class _VitaminBoostMaskPage2State extends State<VitaminBoostMaskPage2> {
  bool isRated = false;
  @override
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
              'assets/images/png/girl2.png',
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
                      child: Image.asset('assets/images/png/arrow.png'),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Coffee Body Scrub',
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
                      child: Text('Hydration',
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
                      width: 93,
                      height: 23,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.black.withOpacity(0.35),
                      ),
                      child: Text('Cellulite Reducing',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
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
                  '423 usd this week',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Draggable Scrollable Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.67,
            minChildSize: 0.65,
            maxChildSize: 0.70,
            builder: (context, scrollController) {
              return Container(
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
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap:(){
                              setState(() {
                                isRated = !isRated;
                              });
                            },
                            child: Icon(
                              isRated ? Icons.star : Icons.star_border,
                              color: isRated ? Colors.amber : Colors.grey,
                              size: 18,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text('4.8', style: GoogleFonts.inter(

                          fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),),
                          SizedBox(width: 10),
                          Image.asset('assets/images/png/timer.png',color: Colors.black),
                          SizedBox(width: 4),
                          Text('15 min',style: GoogleFonts.montserrat(

                          fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),),
                        ],
                      ),
                      SizedBox(height: 34),
                      Text('Overview',style: GoogleFonts.montserrat(

                      fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),),
                      SizedBox(height: 12),
                      Text('Cleansing in the morning is essential to remove any\nsweat, excess oils, and impurities that have built up on\nyour skin overnight. it help to refresh your skin,unclog\npores, and prepare it for the absorption of subsequent\nskincare products.',style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),),
                      SizedBox(height: 5),
                      Text('\$ - 3items',style: GoogleFonts.poppins(

                      fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffD9D9D9),
                      ),),
                      SizedBox(height:30),
                      Text('Ingredients',style: GoogleFonts.inter(

                      fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),),
                      SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildIngredientItem(
                            imagePath: 'assets/images/png/banana.png',
                            name: 'Banana',
                            quantity: '1 piece',
                          ),
                          SizedBox(width: 12),
                          _buildIngredientItem(
                            imagePath: 'assets/images/png/honey.png',
                            name: 'Honey',
                            quantity: '1 tbsp',
                          ),
                          SizedBox(width: 12),
                          _buildIngredientItem(
                            imagePath: 'assets/images/png/lemon.png',
                            name: 'Lemon',
                            quantity: '1 tbsp',
                          ),
                        ],
                      ),
                      SizedBox(height: 70),
                      Center(
                        child: SizedBox(
                          width:269,
                          child: CustomElevatedButton(text: 'Start Treatment',
                          prefixIcon: Image.asset('assets/images/png/lock1.png'),
                              onPressed: () {

                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        quantity,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w300,
          color: Colors.black,
        ),
      ),
    ],
  );
}
