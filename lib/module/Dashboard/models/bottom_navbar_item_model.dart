
class BottomNavbarItemModel {
  final String SvgImageAssets;
  final String text;
  bool isSelected;

  BottomNavbarItemModel({
    required this.SvgImageAssets,
    required this.isSelected,
    required this.text,
  });
  BottomNavbarItemModel copyWith({
    String? SvgImageAssets,
    String? text,
    bool? isSelected,
  }) {
    return BottomNavbarItemModel(
      SvgImageAssets: SvgImageAssets ?? this.SvgImageAssets,
      text: text ?? this.text,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
