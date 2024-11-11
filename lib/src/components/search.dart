import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Search extends StatefulWidget {
  const Search({
    super.key,
    this.cancel
  });

  final Widget? cancel;

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.only(right: widget.cancel != null ? 0 : 8),
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 16,),
              onPressed: () {},
            ),
          ),

          if (widget.cancel != null) Padding(
            padding: const EdgeInsets.only(right: 5),
            child: widget.cancel!,
          ),

        ],
      ),
    );
  }
}