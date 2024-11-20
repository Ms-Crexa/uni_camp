import 'package:flutter/material.dart';

class InformationRow extends StatelessWidget {
  const InformationRow({
    super.key,
    required this.icon,
    required this.content,
  });

  final IconData icon;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color.fromARGB(255, 8, 118, 207)),
        const SizedBox(width: 20),
        Expanded(child: Text(
            content,
            softWrap: true,
            overflow: TextOverflow.visible,
          )
        ),
      ],
    );
  }
}