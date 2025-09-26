import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../Constant/app_color.dart';

class ProfileImageWidget extends StatefulWidget {
  final Function(File) onImageSelected;
  final String? image; // optional network/base64 image

  const ProfileImageWidget({
    Key? key,
    required this.onImageSelected,
    this.image,
  }) : super(key: key);

  @override
  State<ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      widget.onImageSelected(_image!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 114,
      child: Stack(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 102,
              height: 102,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xffDBEAAC),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: _image != null
                    ? Image.file(
                  _image!,
                  fit: BoxFit.cover,
                )
                    : widget.image != null && widget.image!.isNotEmpty
                    ? (widget.image!.startsWith('http') ||
                    widget.image!.startsWith('https')
                    ? Image.network(
                  widget.image!,
                  fit: BoxFit.cover,
                )
                    : Image(
                  image: MemoryImage(
                    base64Decode(widget.image!),
                  ),
                  fit: BoxFit.cover,
                ))
                    : Image.asset(
                  'assets/images/png/women4.png',
                ),
              ),
            ),
          ),
          Positioned(
            top: 82,
            left: 60,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xffDBEAAC),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                child:SvgPicture.asset('assets/images/svg/edit.svg',fit: BoxFit.scaleDown),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
