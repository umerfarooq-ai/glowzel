import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomDropdown1 extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final List<String> options;

  const CustomDropdown1({
    Key? key,
    required this.initialValue,
    required this.onChanged,
    required this.options,
  }) : super(key: key);

  @override
  _CustomDropdown1State createState() => _CustomDropdown1State();
}

class _CustomDropdown1State extends State<CustomDropdown1> {
  late String selectedValue;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant CustomDropdown1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        selectedValue = widget.initialValue;
      });
    }
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    // Calculate center position for the dropdown
    const overlayWidth = 101.0;
    final centerX = offset.dx + (size.width / 2) - (overlayWidth / 2);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: centerX, // Center the overlay horizontally
        top: offset.dy + size.height,
        width: overlayWidth,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isLast = index == widget.options.length - 1;

              return Container(
                color: Colors.white,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          selectedValue = option;
                        });
                        widget.onChanged(option);
                        _toggleDropdown(); // close overlay
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Row(
                          children: [
                            if (option == selectedValue)
                              const Icon(Icons.check, size: 16, color: Colors.black),
                            const SizedBox(width: 4),
                            Text(
                              option,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 0,
                        thickness: 0.5,
                        color: Colors.black.withOpacity(0.05),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min, // Changed from max to min for better centering
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                selectedValue,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  children: [
                    SvgPicture.asset('assets/images/svg/arrow_down.svg'),
                    const SizedBox(height: 2),
                    SvgPicture.asset('assets/images/svg/arrow_up.svg'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}