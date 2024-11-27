import 'package:flutter/material.dart';

class LeftModal extends StatefulWidget {
  const LeftModal(
      {super.key,
      required this.facilities,
      required this.setFacility,
      required this.searchQuery,
      this.searchController
      });

  final List<Map<String, dynamic>> facilities;
  final Function setFacility;
  final String searchQuery;
  final TextEditingController? searchController;

  @override
  State<LeftModal> createState() => _LeftModalState();
}

class _LeftModalState extends State<LeftModal> {
  // Filter the facilities based on the search query
  List<Map<String, dynamic>> get filteredFacilities {
    if (widget.searchQuery.isEmpty) {
      return widget.facilities;
    }

    return widget.facilities.where((facility) {
      final title = facility['name']?.toLowerCase() ?? '';
      final description = facility['description']?.toLowerCase() ?? '';
      final searchQuery = widget.searchQuery.toLowerCase();

      return title.contains(searchQuery) || description.contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
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
          Container(
            height: 65,
            color: Colors.transparent,
          ),
          Expanded(
            child: filteredFacilities.isEmpty
                ? const Center(
                    child: Text(
                      'No results',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredFacilities.length,
                    itemBuilder: (context, index) {
                      final facility = filteredFacilities[index];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              color: Colors.grey.withOpacity(0.5),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: FacilityCard(
                            widget: widget,
                            facility: facility,
                            searchController: widget.searchController),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class FacilityCard extends StatelessWidget {
  const FacilityCard({
    super.key,
    required this.widget,
    required this.facility,
    required this.searchController,
  });

  final LeftModal widget;
  final Map<String, dynamic> facility;
  final TextEditingController? searchController;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        widget.setFacility(facility);
        searchController?.clear();
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.all(0)),
        overlayColor: WidgetStateProperty.all<Color>(
            const Color.fromARGB(255, 238, 238, 238)),
        shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
        elevation: WidgetStateProperty.all<double>(0),
      ),
      child: Row(
        children: [
          // Image section
          SizedBox(
            width: 100,
            height: 100,
            child: Image.network(
              (facility['images'] != null && facility['images'].isNotEmpty) 
                  ? facility['images'][0]
                  : 'https://ol-content-api.global.ssl.fastly.net/sites/default/files/styles/scale_and_crop_center_890x320/public/2023-01/addu-banner.jpg?itok=ZP3cNDCL',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
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

          // Text content section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    facility['name'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    facility['description'] ?? 'No description available',
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
