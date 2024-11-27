// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:uni_camp/src/ui/information_row.dart';
import 'package:intl/intl.dart';
import 'package:uni_camp/src/ui/facility_container.dart';
import 'package:uni_camp/src/ui/open_hours.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacilityModal extends StatefulWidget {
  const FacilityModal({
    super.key,
    required this.selectedPin,
    this.search,
    required this.isEditing,
  });

  final Widget? search;
  final Function isEditing;
  final Map<String, dynamic>? selectedPin;

  @override
  State<FacilityModal> createState() => _FacilityModal();
}

class _FacilityModal extends State<FacilityModal> {
  final FlutterCarouselController buttonCarouselController =
      FlutterCarouselController();

  // Function to delete facility from Firestore
  Future<void> deleteFacility(String facilityId) async {
    try {
      await FirebaseFirestore.instance
          .collection('facilities')
          .doc(facilityId)
          .delete();
      toastification.show(
        context: context,
        title: const Text('Facility Successfully Deleted!'),
        style: ToastificationStyle.flatColored,
        type: ToastificationType.success,
        alignment: Alignment.topCenter,
        autoCloseDuration: const Duration(seconds: 3),
      );
      Navigator.of(context).pop();
    } catch (e) {
      toastification.show(
        context: context,
        title: const Text('An error occurred!'),
        style: ToastificationStyle.flatColored,
        type: ToastificationType.error,
        alignment: Alignment.topCenter,
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  //Confirmation dialog
  Future<void> showDeleteConfirmationDialog(String facilityId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to delete this facility? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteFacility(facilityId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: double.infinity,
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  FlutterCarousel(
                    options: FlutterCarouselOptions(
                      autoPlay: true,
                      aspectRatio: 16 / 9,
                      viewportFraction: 1.0,
                      enableInfiniteScroll: true,
                      controller: buttonCarouselController,
                    ),
                    items: widget.selectedPin?['images'].isNotEmpty
                        ? widget.selectedPin!['images']
                            .map<Widget>(
                              (imageUrl) => GestureDetector(
                                onTap: () {
                                  _showFullScreenImage(context, imageUrl);
                                },
                                child: Image.network(
                                  imageUrl ??
                                      'https://ol-content-api.global.ssl.fastly.net/sites/default/files/styles/scale_and_crop_center_890x320/public/2023-01/addu-banner.jpg?itok=ZP3cNDCL',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 200,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text(
                                        'Failed to load image',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                            .toList()
                        : [
                            GestureDetector(
                              onTap: () {
                                _showFullScreenImage(context,
                                    'https://ol-content-api.global.ssl.fastly.net/sites/default/files/styles/scale_and_crop_center_890x320/public/2023-01/addu-banner.jpg?itok=ZP3cNDCL');
                              },
                              child: Image.network(
                                'https://ol-content-api.global.ssl.fastly.net/sites/default/files/styles/scale_and_crop_center_890x320/public/2023-01/addu-banner.jpg?itok=ZP3cNDCL',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                              ),
                            ),
                          ],
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        buttonCarouselController.previousPage();
                      },
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon:
                          const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: () {
                        buttonCarouselController.nextPage();
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            FacilityContainer(
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

            const Divider(
              thickness: 2,
            ),

            // Additional details
            FacilityContainer(
              children: [
                InformationRow(
                  icon: FontAwesomeIcons.list,
                  content: widget.selectedPin?["category"] ?? 'No category',
                ),
                const SizedBox(height: 20),
                (widget.selectedPin?['openHours'] is Map<String, dynamic>)
                    ? OpenHours(
                        openHours: widget.selectedPin?['openHours'] ?? {},
                      )
                    : const InformationRow(
                        icon: FontAwesomeIcons.clock,
                        content: 'No hours available',
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

            const Divider(
              thickness: 2,
            ),

            FacilityContainer(
              children: [
                InformationRow(
                  icon: FontAwesomeIcons.calendarPlus,
                  content: widget.selectedPin?["created_at"] != null
                      ? DateFormat('yyyy-MM-dd HH:mm')
                          .format(widget.selectedPin?["created_at"].toDate())
                      : 'No Date',
                ),
                const SizedBox(height: 20),
                InformationRow(
                  icon: FontAwesomeIcons.clockRotateLeft,
                  content: widget.selectedPin?["updated_at"] != null
                      ? DateFormat('yyyy-MM-dd HH:mm')
                          .format(widget.selectedPin?["updated_at"].toDate())
                      : 'No Date',
                ),
              ],
            ),

            const Divider(
              thickness: 2,
            ),

            // Actions
            FacilityContainer(
              horizontalPadding: 25,
              verticalPadding: 20,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        widget.isEditing(widget.selectedPin);
                      },
                      style: ButtonStyle(
                        fixedSize: WidgetStateProperty.all(const Size(140, 35)),
                      ),
                      child: const Text('Edit'),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     if (widget.selectedPin != null) {
                    //       showDeleteConfirmationDialog(
                    //           widget.selectedPin!['id']);
                    //     }
                    //   },
                    //   style: ButtonStyle(
                    //     fixedSize: WidgetStateProperty.all(const Size(140, 35)),
                    //   ),
                    //   child: const Text('Delete'),
                    // ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showFullScreenImage(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        child: Center(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      );
    },
  );
}
