import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Glowzel/module/notification/widget/notification-toggle.dart';
import 'package:Glowzel/module/notification/widget/time_reminder_widget.dart';
import '../../../../Constant/app_color.dart';
import '../../ui/widget/custom_app_bar.dart';

class SetReminderPage extends StatefulWidget {
  const SetReminderPage({super.key});

  @override
  State<SetReminderPage> createState() => _SetReminderPageState();
}

class _SetReminderPageState extends State<SetReminderPage> {
  bool _amRoutineEnabled = false;
  bool _pmRoutineEnabled = false;
  bool _pushNotificationEnabled = false;
  bool _inAppNotificationEnabled = false;
  bool _educationalTipsEnabled = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.palePurple,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        showBackButton: true,
        text: 'Notifications',
      ),
      body:Padding(
            padding: const EdgeInsets.only(top:24,left: 30,right: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 411,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: LinearGradient(
                        colors: [
                          Color(0xffFFFFFF),
                          Color(0xffFFFFFF).withOpacity(0.46),
                          Color(0xffFFFFFF).withOpacity(0.2),
                        ]),
                    border: Border.all(
                      width: 1,
                      color: Colors.white,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reminders',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'AM Routine',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              NotificationToggle(
                                isEnabled: _amRoutineEnabled,
                                onToggle: (value) {
                                  setState(() {
                                    _amRoutineEnabled = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          TimeReminderWidget(),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PM Routine',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              NotificationToggle(
                                isEnabled: _pmRoutineEnabled ,
                                onToggle: (value) {
                                  setState(() {
                                    _pmRoutineEnabled  = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          TimeReminderWidget(),
                        ],
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Push Notifications',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Push Notifications',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          NotificationToggle(
                            isEnabled: _pushNotificationEnabled ,
                            onToggle: (value) {
                              setState(() {
                                _pushNotificationEnabled  = value;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'In-App Notifications',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          NotificationToggle(
                            isEnabled: _inAppNotificationEnabled,
                            onToggle: (value) {
                              setState(() {
                                _inAppNotificationEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Educational Tips',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Educational Tips',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          NotificationToggle(
                            isEnabled: _educationalTipsEnabled,
                            onToggle: (value) {
                              setState(() {
                                _educationalTipsEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
