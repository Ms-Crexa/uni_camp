import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:toastification/toastification.dart';
import 'dart:typed_data';

class RightModal extends StatefulWidget {
  const RightModal({
    super.key,
    required this.onCancel,
    required this.selectedPin,
    required this.onSelectPin,
    required this.temptData,
  });

  final Function() onCancel;
  final LatLng selectedPin;
  final Function(Map<String, dynamic>) onSelectPin;
  final Map<String, dynamic>? temptData;

  @override
  State<RightModal> createState() => _RightModalState();
}

class _RightModalState extends State<RightModal> {
  final _formKey = GlobalKey<FormState>();

  Uint8List? imageBytes;
  final TextEditingController facilityNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController openHoursController = TextEditingController();

  String? selectedCategory;
  String? selectedBuilding;

  List<Map<String, String>> categories = [
    {'value': 'Cafeteria', 'label': 'Cafeteria'},
    {'value': 'Library', 'label': 'Library'},
    {'value': 'Laboratory', 'label': 'Laboratory'},
    {'value': 'Clinic', 'label': 'Clinic'},
    {'value': 'Gym', 'label': 'Gym'},
  ];

  List<Map<String, String>> buildings = [
    {'value': 'Finster', 'label': 'Finster'},
    {
      'value': 'Community Center of the First Companions',
      'label': 'Community Center of the First Companions'
    },
    {'value': 'Jubilee Hall', 'label': 'Jubilee Hall'},
    {'value': 'Bellarmine Hall', 'label': 'Bellarmine Hall'},
    {'value': 'Wieman Hall', 'label': 'Wieman Hall'},
    {'value': 'Dotterweich Hall', 'label': 'Dotterweich Hall'},
    {'value': 'Gisbert Hall', 'label': 'Gisbert Hall'},
    {'value': 'Canasius Hall', 'label': 'Canasius Hall'},
    {'value': 'Thalibut Hall', 'label': 'Thalibut Hall'},
    {'value': 'Del Rosario Hall', 'label': 'Del Rosario Hall'},
    {
      'value': 'Chapel of Our Lady of the Assumption',
      'label': 'Chapel of Our Lady of the Assumption'
    },
  ];

  // if there is a temptData, set the values of the fields
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // If temptData is available, populate the form fields
    if (widget.temptData != null) {
      setState(() {
        facilityNameController.text = widget.temptData?['facilityName'];
        descriptionController.text = widget.temptData?['description'];
        openHoursController.text = widget.temptData?['openHours'];
        selectedCategory = widget.temptData?['category'];
        selectedBuilding = widget.temptData?['building'];
        imageBytes = widget.temptData?['image'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      child: Material(
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          // margin: const EdgeInsets.only(right: 10),
          width: 400,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: const BorderRadius.all(Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding:
                      EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('New Facility',
                        style: TextStyle(
                          fontSize: 20,
                          color:Color.fromARGB(255, 0, 84, 153),
                          fontWeight: FontWeight.bold,
                      )),
                      SizedBox(height: 5),
                      Text('Add a new facility to the map',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 109, 109, 109),
                          fontWeight: FontWeight.w100,
                      )),
                    ],
                  ),
                ),

                const Divider(thickness: 2),

                // Basic Information
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(FontAwesomeIcons.circleInfo, size: 18, color:Color.fromARGB(255, 8, 118, 207)),
                                  SizedBox(width: 7),
                                  Text('Basic Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w100,
                                  )),
                                ],
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: facilityNameController,
                                decoration: const InputDecoration(
                                  hintText: 'Facility name',
                                  isDense: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the facility name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: descriptionController,
                                decoration: const InputDecoration(
                                  hintText: 'Description',
                                  isDense: true,
                                ),
                                maxLines: 5,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a description';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        const Divider(thickness: 2),

                        // Operational details
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(FontAwesomeIcons.gear, size: 18, color:Color.fromARGB(255, 8, 118, 207)),
                                  SizedBox(width: 7),
                                  Text('Operational Details',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w100,
                                  )),
                                ],
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: openHoursController,
                                decoration: const InputDecoration(
                                  hintText: 'Open hours',
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Category',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54),
                              ),
                              const SizedBox(height: 5),
                              DropdownButtonFormField<String>(
                                value: selectedCategory,
                                items: categories.map((data) {
                                  return DropdownMenuItem<String>(
                                    value: data['value']!,
                                    child: Text(data['label']!),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategory = value;
                                  });
                                },
                                validator: (value) => value == null
                                    ? 'Please select a category'
                                    : null,
                              ),
                            ],
                          ),
                        ),

                        const Divider(thickness: 2),
                        
                        // Location and image
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(FontAwesomeIcons.mapPin, size: 18, color:Color.fromARGB(255, 8, 118, 207)),
                                  SizedBox(width: 5),
                                  Text('Location',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w100,
                                  )),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Building',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54),
                              ),
                              DropdownButtonFormField<String>(
                                value: selectedBuilding,
                                items: buildings.map((data) {
                                  return DropdownMenuItem<String>(
                                    value: data['value']!,
                                    child: Text(data['label']!),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedBuilding = value;
                                  });
                                },
                                validator: (value) => value == null
                                    ? 'Please select a building'
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () async {
                                  var picked = await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['jpg', 'png', 'jpeg'],
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      imageBytes = picked.files.single.bytes;
                                    });
                                    toastification.show(
                                      // ignore: use_build_context_synchronously
                                      context: context,
                                      title: const Text(
                                          'Image successfully uploaded!'),
                                      style: ToastificationStyle.flatColored,
                                      type: ToastificationType.success,
                                      alignment: Alignment.topCenter,
                                      autoCloseDuration: const Duration(seconds: 3),
                                    );
                                  }
                                },
                                child: const Text('Upload Image'),
                              ),
                              if (imageBytes != null) ...[
                                const SizedBox(height: 10),
                                Image.memory(imageBytes!),
                              ],
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  Map<String, dynamic> formData = {
                                    'facilityName': facilityNameController.text,
                                    'description': descriptionController.text,
                                    'openHours': openHoursController.text,
                                    'category': selectedCategory,
                                    'building': selectedBuilding,
                                    'image': imageBytes,
                                    'selectedPin': widget.selectedPin,
                                  };
                          
                                  // Pass the map data to onSelectPin
                                  widget.onSelectPin(formData);
                                },
                                child: const Text('Select Pin on Map'),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                    'Selected pin: ${widget.selectedPin.latitude}, ${widget.selectedPin.longitude}'),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),

                      Column(
                        children: [
                          const Divider(thickness: 2),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 5, bottom: 30),
                            child: Row(
                              children: [
                                TextButton(
                                    onPressed: widget.onCancel,
                                    style: ButtonStyle(
                                      fixedSize: WidgetStateProperty.all(
                                          const Size(100, 35)),
                                      backgroundColor: WidgetStateProperty.all(
                                          const Color.fromARGB(255, 160, 160, 160)),
                                    ),
                                    child: const Text('Cancel', style: TextStyle(
                                      color: Colors.white,
                                    ))
                                ),
                                const SizedBox(width: 10),
                                // store in firebase
                                TextButton(
                                  style: ButtonStyle(
                                      fixedSize: WidgetStateProperty.all(
                                          const Size(100, 35)),
                                      backgroundColor: WidgetStateProperty.all(
                                          const Color.fromARGB(255, 44, 97, 138)),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState?.validate() ?? false) {
                                      // Get current user
                                      User? user = FirebaseAuth.instance.currentUser;
                                      String? userName =
                                          user?.displayName ?? 'Unknown User';

                                      Map<String, dynamic> formData = {
                                        'facilityName': facilityNameController.text,
                                        'description': descriptionController.text,
                                        'openHours': openHoursController.text,
                                        'category': selectedCategory,
                                        'building': selectedBuilding,
                                        'selectedPin': {
                                          'latitude': widget.selectedPin.latitude,
                                          'longitude': widget.selectedPin.longitude,
                                        },
                                        'timestamp': FieldValue.serverTimestamp(),
                                        'added by': userName,
                                      };

                                      if (imageBytes != null) {
                                        formData['image'] = imageBytes;
                                      }

                                      // Save to Firestore
                                      await FirebaseFirestore.instance
                                          .collection('facilities')
                                          .add(formData);

                                      toastification.show(
                                        // ignore: use_build_context_synchronously
                                        context: context,
                                        title: const Text(
                                            'Facility Successfully Saved!'),
                                        style: ToastificationStyle.flatColored,
                                        type: ToastificationType.success,
                                        alignment: Alignment.topCenter,
                                        autoCloseDuration: const Duration(seconds: 3),
                                      );

                                      widget.onCancel();
                                    }
                                  },
                                  child: const Text('Submit', style: TextStyle(
                                    color: Colors.white,
                                  ))
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                        
                      ],
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
