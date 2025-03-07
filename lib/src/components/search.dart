import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Search extends StatefulWidget {
  const Search({
    super.key,
    required this.onChanged,
    required this.gotTapped,
    required this.searchController,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback gotTapped;
  final TextEditingController searchController;

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {

  bool get isEmpty => widget.searchController.text.isEmpty;

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
              child: TextField(
                controller: widget.searchController,
                onChanged: (_) {
                  setState(() {
                    widget.onChanged(widget.searchController.text);
                  });
                },
                onTap: widget.gotTapped,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
    
          // Display the "X" button when there is text in the TextField
          if (widget.searchController.text.isNotEmpty) 
            IconButton(
              icon: const Icon(FontAwesomeIcons.x, size: 16, color: Colors.blue),
              onPressed: () {
                widget.searchController.clear();
                widget.onChanged('');
              },
            ),
    
          // Search icon with a border
          Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.grey.withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 16),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}