import 'package:Glowzel/Constant/app_color.dart';
import 'package:Glowzel/core/network/dio_client.dart';
import 'package:Glowzel/core/security/secure_auth_storage.dart';
import 'package:Glowzel/core/storage_services/storage_service.dart';
import 'package:Glowzel/module/Home/widget/skin_progress_summary.dart';
import 'package:Glowzel/module/authentication/repository/auth_repository.dart';
import 'package:Glowzel/module/authentication/repository/session_repository.dart';
import 'package:Glowzel/module/diary/model/reminder_input.dart';
import 'package:Glowzel/module/diary/model/reminder_response.dart';
import 'package:Glowzel/module/diary/widgets/drop_down.dart';
import 'package:Glowzel/module/user/repository/user_account_repository.dart';
import 'package:Glowzel/ui/button/custom_elevated_button.dart';
import 'package:Glowzel/ui/widget/nav_router.dart';
import 'package:Glowzel/utils/extensions/string_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class UnderEyeMaskPage extends StatefulWidget {
  const UnderEyeMaskPage({super.key});

  @override
  State<UnderEyeMaskPage> createState() => _UnderEyeMaskPageState();
}

class _UnderEyeMaskPageState extends State<UnderEyeMaskPage> {
  String selectedDuration = 'Daily';
  DateTime selectedDate = DateTime.now();
  bool isEnabled = false;
  Set<int> selectedIndices = {};
  TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
  late StorageService storageService;
  late AuthRepository authRepository;
  late SessionRepository sessionRepository;
  ReminderData? _latestReminder;
  String? _error;

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
    loadLatestReminder();
  }

  int daysInMonth(DateTime date) {
    final firstDayNextMonth = (date.month == 12)
        ? DateTime(date.year + 1, 1, 1)
        : DateTime(date.year, date.month + 1, 1);
    return firstDayNextMonth.subtract(const Duration(days: 1)).day;
  }


  Future<void> _onSubmitReminder() async {
    try {
      final now = DateTime.now();
      final formattedTime = DateFormat("HH:mm").format(
        DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute),
      );

      List<int> days = [];
      if (selectedDuration == "Daily") {
        days = [];
      } else if (selectedDuration == "Weekly") {
        days = selectedIndices.map((i) => i + 1).toList(); // Mon=1 … Sun=7
      } else if (selectedDuration == "Monthly") {
        final totalDays = daysInMonth(selectedDate);
        days = List.generate(30, (i) => i + 1); // 1–30
      }

      final input = ReminderInput(
        name: "Under Eye Mask",
        time: formattedTime,
        frequency: selectedDuration.toLowerCase(),
        selectedDays: days,
      );

      final response = await authRepository.createReminder(input);

      if (response.data != null && response.data?.id != null) {
        await sessionRepository.setReminderId(response.data!.id.toString());
        final ReminderId=await sessionRepository.getReminderId();
        print('Reminder id is ${ReminderId}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? "Routine Updated Successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> loadLatestReminder() async {
    try {
      final reminderId = await sessionRepository.getReminderId();

      if (reminderId == null) {
        setState(() {
          _error = "No reminder set yet.";
          _latestReminder = null;
        });
        return;
      }

      final response = await authRepository.getReminder(int.parse(reminderId));

      setState(() {
        _latestReminder = response.data;

        if (_latestReminder != null) {
          switch (_latestReminder!.frequency.toLowerCase()) {
            case "daily":
              selectedDuration = "Daily";
              break;
            case "weekly":
              selectedDuration = "Weekly";
              break;
            case "monthly":
              selectedDuration = "Monthly";
              break;
            default:
              selectedDuration = "Daily"; // fallback
          }
          if (_latestReminder!.isActive) {
          final timeString = _latestReminder!.time;
          try {
            final parts = timeString.split(":");
            final hour = int.tryParse(parts[0]) ?? 9;
            final minute = int.tryParse(parts[1]) ?? 0;
            selectedTime = TimeOfDay(hour: hour, minute: minute);
          } catch (_) {
            selectedTime = const TimeOfDay(hour: 9, minute: 0);
          }

          if (_latestReminder!.frequency.toLowerCase() == "weekly" ||
              _latestReminder!.frequency.toLowerCase() == "monthly") {
            final days = _latestReminder!.selectedDays.split(",");
            selectedIndices = days
                .where((d) => d.isNotEmpty)
                .map((d) => int.parse(d) - 1)
                .toSet();
          } else {
            selectedIndices.clear();
          }

          isEnabled = _latestReminder!.isActive;
        }

        _error = null;
      }});
    } catch (e) {
      setState(() {
        _error = e.toString();
        _latestReminder = null;
      });
      print("❌ Error loading reminder: $e");
    }
  }

  Future<void> _onUpdateReminder() async {
    try {
      final reminderId = await sessionRepository.getReminderId();

      if (reminderId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No reminder found to update.")),
        );
        return;
      }

      final input = {
        "name": _latestReminder?.name ?? "Routine",
        "time":
        "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
        "frequency": selectedDuration.toLowerCase(),
        "selected_days": selectedDuration.toLowerCase() == "weekly"
            ? selectedIndices.map((e) => (e + 1).toString()).join(",")
            : selectedDuration.toLowerCase() == "monthly"
            ? List.generate(daysInMonth(selectedDate), (i) => (i + 1).toString()).join(",")
            : "",
        "is_active": isEnabled,
      };

      final response = await authRepository.updateReminder(
        reminderId: int.parse(reminderId),
        input: input,
      );

      if (response["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Reminder updated!")),
        );

        // Reload to refresh UI
        await loadLatestReminder();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Update failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating reminder: $e")),
      );
    }
  }

  Future<void> _onToggleReminder() async {
    try {
      final reminderId = await sessionRepository.getReminderId();

      if (reminderId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No reminder found to toggle.")),
        );
        return;
      }

      final response = await authRepository.toggleReminder(int.parse(reminderId));

      if (response["success"] == true) {
        setState(() {
          isEnabled = response["data"]["is_active"]; // use backend status
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Reminder toggled")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Toggle failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error toggling reminder: $e")),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey3,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            width: 393,
            height: 330,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 17, right: 17, top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        NavRouter.pop(context);
                      },
                      icon:SvgPicture.asset('assets/images/svg/arrow3.svg'),
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Color(0xff00A8B5),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(child: SvgPicture.asset('assets/images/svg/mask1.svg')),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Under eye mask',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Addresses the delicate under-eye area, reducing signs of fatigue and aging.',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 45,
                    width: 156,
                    child: Stack(
                      children: [
                        Positioned(left: 0, child: CircleAvatar(radius: 22.5, backgroundImage: AssetImage('assets/images/png/w1.png'))),
                        Positioned(left: 24, child: CircleAvatar(radius: 22.5, backgroundImage: AssetImage('assets/images/png/w2.png'))),
                        Positioned(left: 52, child: CircleAvatar(radius: 22.5, backgroundImage: AssetImage('assets/images/png/w3.png'))),
                        Positioned(left: 80, child: CircleAvatar(radius: 22.5, backgroundImage: AssetImage('assets/images/png/w4.png'))),
                        Positioned(left: 112, child: CircleAvatar(radius: 22.5, backgroundImage: AssetImage('assets/images/png/w5.png'))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 0),
                  Text(
                    '4.6K people have set',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 17, right: 17, top: 22, bottom: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: SvgPicture.asset('assets/images/svg/reload.svg'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'I want to repeat this',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    Container(
                      height: 30,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: CustomDropdown1(
                          initialValue: selectedDuration,
                          onChanged: (value) {
                            setState(() {
                              selectedDuration = value;
                            });
                          }, options: ['Daily', 'Weekly', 'Monthly'],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    const days = ["M", "T", "W", "T", "F", "S", "S"];
                    return ReminderWidget(
                      title: days[i],
                      isSelected: selectedIndices.contains(i),
                      onTap: (_latestReminder == null || isEnabled)
                          ? () {
                        setState(() {
                          if (selectedIndices.contains(i)) {
                            selectedIndices.remove(i);
                          } else {
                            selectedIndices.add(i);
                          }
                        });
                      }
                          : null,
                    );
                  }),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.grey4, thickness: 1),

          Padding(
            padding: const EdgeInsets.only(left: 17, right: 17, top: 18, bottom: 20),
            child: Row(
              children: [
                SvgPicture.asset('assets/images/svg/calendar2.svg'),
                const SizedBox(width: 18),
                Text(
                  'Start the routine from',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
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
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    height: 29,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        DateFormat("dd/MM/yyyy").format(selectedDate),
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.grey4, thickness: 1),

          Padding(
            padding: const EdgeInsets.only(left: 17, right: 17, top: 22),
            child: Row(
              children: [
                SvgPicture.asset('assets/images/svg/clock.svg'),
                const SizedBox(width: 18),
                Text(
                  'Remind me at',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                ReminderTimePicker(
                  initialTime: selectedTime,
                  onTimeChanged: (time) {
                    setState(() {
                      selectedTime = time;
                    });
                  },
                ),
              ],
            ),
          ),
          const Spacer(),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 37,right: 37),
                child: CustomElevatedButton(
                  text: _latestReminder == null ? 'Create Reminder' : 'Update Reminder',
                  onPressed: _latestReminder == null
                      ? _onSubmitReminder
                      : _onUpdateReminder,
                ),
              ),
              const SizedBox(height: 5),
              if (_latestReminder != null)
                TextButton(
                  onPressed: _onToggleReminder,
                  child: Text(
                    isEnabled ? 'Disable Reminder' : 'Enable Reminder',
                    style: GoogleFonts.poppins(
                      color: AppColors.lightGreen2,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReminderTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const ReminderTimePicker({
    Key? key,
    required this.initialTime,
    required this.onTimeChanged,
  }) : super(key: key);

  @override
  _ReminderTimePickerState createState() => _ReminderTimePickerState();
}

class _ReminderTimePickerState extends State<ReminderTimePicker> {
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime;
  }

  @override
  void didUpdateWidget(covariant ReminderTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTime != widget.initialTime) {
      setState(() {
        selectedTime = widget.initialTime;
      });
    }
  }


  void _incrementHour() {
    setState(() {
      int newHour = (selectedTime.hour + 1) % 24;
      selectedTime = TimeOfDay(hour: newHour, minute: selectedTime.minute);
      widget.onTimeChanged(selectedTime);
    });
  }

  void _decrementHour() {
    setState(() {
      int newHour = (selectedTime.hour - 1) < 0 ? 23 : selectedTime.hour - 1;
      selectedTime = TimeOfDay(hour: newHour, minute: selectedTime.minute);
      widget.onTimeChanged(selectedTime);
    });
  }

  void _toggleAmPm() {
    setState(() {
      int newHour = (selectedTime.hour + 12) % 24;
      selectedTime = TimeOfDay(hour: newHour, minute: selectedTime.minute);
      widget.onTimeChanged(selectedTime);
    });
  }

  Future<void> _editTimeManually() async {
    final controller = TextEditingController(
      text: DateFormat("HH:mm").format(
        DateTime(0, 0, 0, selectedTime.hour, selectedTime.minute),
      ),
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Enter Time (HH:mm)"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.datetime,
            decoration: const InputDecoration(
              hintText: "e.g. 09:30",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      try {
        final parts = result.split(":");
        if (parts.length == 2) {
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);
          if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
            setState(() {
              selectedTime = TimeOfDay(hour: hour, minute: minute);
              widget.onTimeChanged(selectedTime);
            });
          }
        }
      } catch (e) {
        // invalid input → ignore
      }
    }
  }

  String _formatHourMinute(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isAm = selectedTime.period == DayPeriod.am;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _decrementHour,
          icon: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: AppColors.lightGreen,
            ),
            child:SvgPicture.asset('assets/images/svg/minus.svg',fit:BoxFit.scaleDown),

          ),
        ),
        InkWell(
          onTap: _editTimeManually,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatHourMinute(selectedTime),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _toggleAmPm,
                child: Text(
                  isAm ? "AM" : "PM",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _incrementHour,
          icon: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: AppColors.lightGreen,
            ),
            child:SvgPicture.asset('assets/images/svg/plus.svg',fit:BoxFit.scaleDown),
          ),
        ),
      ],
    );
  }
}

class ReminderWidget extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  const ReminderWidget({
    Key? key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: isSelected? Color(0xffDBEAAC):Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  offset: Offset(0, 2),
                  color: Colors.black.withOpacity(0.25),
                ),
              ],
            ),
            child: Center(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}





