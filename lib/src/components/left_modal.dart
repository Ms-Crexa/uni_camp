import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uni_camp/src/components/information_row.dart';

class LeftModal extends StatefulWidget {
  const LeftModal({
    super.key,
    required this.selectedPin,
    required this.children,
    required this.search,
  });

  final Widget search;
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
        width: 350,
        decoration: BoxDecoration(
          color: Colors.white,
          // borderRadius: const BorderRadius.only(
          //   topRight: Radius.circular(10),
          //   bottomRight: Radius.circular(10),
          // ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // widget.selectedPin?['image'] != null && widget.selectedPin?['image'].isNotEmpty
                //   ? FittedBox(
                //       fit: BoxFit.fitWidth,
                //       child: Image.asset('assets/images/bg.png'),
                //     )
                //   : const SizedBox(height: 30)

                FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Image.asset(
                      'assets/images/bg.png',
                    )),

                Positioned(
                  top: 15,
                  left: 25,
                  child: widget.search,
                ),
              ],
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.selectedPin?["facilityName"] ?? 'No Name Available',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(widget.selectedPin?["description"] ??
                      'No description available')
                ],
              ),
            ),

            const Divider(
              thickness: 2,
            ),

            // Additional details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InformationRow(
                    icon: FontAwesomeIcons.list,
                    content: widget.selectedPin?["category"] ?? 'No category',
                  ),
                  const SizedBox(height: 20),
                  InformationRow(
                    icon: FontAwesomeIcons.clock,
                    content: widget.selectedPin?["openHours"] ??
                        'No hours available',
                  ),
                  const SizedBox(height: 20),
                  InformationRow(
                    icon: FontAwesomeIcons.building,
                    content: widget.selectedPin?["building"] ??
                        'No building information',
                  ),
                  const SizedBox(height: 20),
                  InformationRow(
                    icon: FontAwesomeIcons.envelope,
                    content: widget.selectedPin?["email"] ??
                        'No contact details available',
                  ),
                  const SizedBox(height: 20),
                  InformationRow(
                    icon: FontAwesomeIcons.phone,
                    content: widget.selectedPin?["number"] ??
                        'No contact details available',
                  ),
                ],
              ),
            ),

            const Divider(
              thickness: 2,
            ),

            // Actions
            ...widget.children,
          ],
        ),
      ),
    );
  }
}
