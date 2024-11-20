import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uni_camp/src/components/information_row.dart';

class FacilityModal extends StatefulWidget {
  const FacilityModal({
    super.key,
    required this.selectedPin,
    required this.children,
    this.search,
  });

  final Widget? search;
  final List<Widget> children;
  final Map<String, dynamic>? selectedPin;

  @override
  State<FacilityModal> createState() => _FacilityModal();
}

class _FacilityModal extends State<FacilityModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Stack(
              children: [
                // widget.selectedPin?['image'] != null && widget.selectedPin?['image'].isNotEmpty
                //   ? FittedBox(
                //       fit: BoxFit.fitWidth,
                //       child: Image.asset('assets/images/bg.png'),
                //     )
                //   : const SizedBox(height: 30)

                Image.network(
                  widget.selectedPin?['image'] ??
                      'https://ol-content-api.global.ssl.fastly.net/sites/default/files/styles/scale_and_crop_center_890x320/public/2023-01/addu-banner.jpg?itok=ZP3cNDCL',
                  fit: BoxFit.cover,
                  height: double.infinity,
                ),

                // Positioned(
                //   top: 15,
                //   left: 25,
                //   child: SizedBox(
                //     width: 300,
                //     child: widget.search,
                //   ),
                // ),
              ],
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.selectedPin?["name"] ?? 'No Name Available',
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
                  content:
                      widget.selectedPin?["openHours"] ?? 'No hours available',
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
    );
  }
}
