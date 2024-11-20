import 'package:flutter/material.dart';

class FacilityContainer extends StatelessWidget {
  const FacilityContainer({super.key, required this.children, this.verticalPadding, this.horizontalPadding});

  final List<Widget> children;
  final double? verticalPadding;
  final double? horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 25, vertical: verticalPadding ?? 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...children,
        ],
      ),
    );
  }
}