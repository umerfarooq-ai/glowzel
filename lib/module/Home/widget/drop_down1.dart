import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomDropdown extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final List<String> options;

  const CustomDropdown({
    Key? key,
    required this.initialValue,
    required this.onChanged,
    required this.options,
  }) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late String selectedValue;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
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

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: 101,
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
                        child: Text(
                          option,
                          style: const TextStyle(fontSize: 14),
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
    return GestureDetector(
      onTap: _toggleDropdown,
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              selectedValue,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(width: 6),
            SvgPicture.asset('assets/images/svg/arrow3.svg'),
          ],
        ),
      ),
    );
  }
}