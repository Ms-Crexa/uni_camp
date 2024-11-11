import 'package:flutter/material.dart';

class LeftModal extends StatefulWidget {
  const LeftModal({
    super.key,
    required this.selectedPin,
    required this.children,
  });

  final List<Widget> children;
  final Map<String, dynamic>? selectedPin;

  @override
  State<LeftModal> createState() => _LeftModalState();
}

class _LeftModalState extends State<LeftModal> {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...widget.children,
          ],
        ),
      ),
    );
  }
}