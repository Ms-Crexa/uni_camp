// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:toastification/toastification.dart';
import 'dart:typed_data';
// import 'package:image/image.dart' as img;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:uni_camp/src/components/open_hours_form.dart';

class RightModal extends StatefulWidget {
  const RightModal(
      {super.key,
      required this.onCancel,
      required this.selectedPin,
      required this.onSelectPin,
      required this.temptData,
      required this.isEditing});

  final Function() onCancel;
  final LatLng selectedPin;
  final Function(Map<String, dynamic>) onSelectPin;
  final Map<String, dynamic>? temptData;
  final Map<String, dynamic> isEditing;

  @override
  State<RightModal> createState() => _RightModalState();
}

class _RightModalState extends State<RightModal> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isVisible = true;

  List<Uint8List?> imageBytes = [];
  final List<html.File> _selectedPhotos = [];
  final bool _isUploading = false;
  final List<String> _photoPreviewUrls = [];
  final TextEditingController facilityNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  List<Map<String, dynamic>> schedules = [];

  String? selectedCategory;
  String? selectedBuilding;

  List<Map<String, String>> categories = [
    {'value': 'Cafeteria', 'label': 'Cafeteria'},
    {'value': 'Library', 'label': 'Library'},
    {'value': 'Laboratory', 'label': 'Laboratory'},
    {'value': 'Clinic', 'label': 'Clinic'},
    {'value': 'Gym', 'label': 'Gym'},
    {'value': 'Technology', 'label': 'Technology'},
    {'value': 'Auditorium', 'label': 'Auditorium'},
    {'value': 'Student Services', 'label': 'Student Services'},
    {'value': 'Study', 'label': 'Study'},
    {'value': 'Sports', 'label': 'Sports'},
    {'value': 'Alumni', 'label': 'Alumni'},
    {'value': 'Administrative', 'label': 'Admnistrative'},
    {'value': 'Events', 'label': 'Events'},
    {'value': 'Community', 'label': 'Community'},
    {'value': 'Health', 'label': 'Health'},
    {'value': 'Office', 'label': 'Office'},
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
    {'value': 'Martin Hall', 'label': 'Martin Hall'}
  ];

  Future<List<String>> _uploadPhotos() async {
  List<String> photoUrls = [];

  for (html.File photo in _selectedPhotos) {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}_${photo.name}';
    Reference storageRef = FirebaseStorage.instance.ref().child(fileName); // Without the "location_photos/" path

    try {
      // Create a FileReader
      final reader = html.FileReader();
      // Read the file as array buffer
      reader.readAsArrayBuffer(photo);

      // Wait for the reader to complete
      await reader.onLoadEnd.first;

      // Get the result as Blob
      final blob = html.Blob([reader.result]);

      // Determine the Content-Type based on file extension (simplified example)
      String contentType = 'application/octet-stream'; // Default content type
      if (photo.name.endsWith('.png')) {
        contentType = 'image/png';
      } else if (photo.name.endsWith('.jpg') || photo.name.endsWith('.jpeg')) {
        contentType = 'image/jpeg';
      } else if (photo.name.endsWith('.gif')) {
        contentType = 'image/gif';
      }

      // Set the metadata with contentType
      final metadata = SettableMetadata(
        contentType: contentType,
      );

      // Upload the file with the metadata
      await storageRef.putBlob(blob, metadata);
      
      // Get the download URL
      String downloadUrl = await storageRef.getDownloadURL();
      photoUrls.add(downloadUrl);
    } catch (e) {
      print('Error uploading photo: $e');
      throw e;
    }
  }

  return photoUrls;
}

  // Method to pick images for web
  Future<void> _pickImages() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..multiple = true;

    input.click();

    await input.onChange.first;

    if (input.files != null) {
      setState(() {
        _selectedPhotos.addAll(input.files!);
        // Create preview URLs for the selected images
        toastification.show(
          // ignore: use_build_context_synchronously
          context: context,
          title: const Text(
              'Image successfully uploaded!'),
          style: ToastificationStyle.flatColored,
          type: ToastificationType.success,
          alignment: Alignment.topCenter,
          autoCloseDuration:
              const Duration(seconds: 3),
        );
        for (var file in input.files!) {
          final reader = html.FileReader();
          reader.readAsDataUrl(file);
          reader.onLoad.listen((e) {
            setState(() {
              _photoPreviewUrls.add(reader.result as String);
            });
          });
        }
      });
    }
  }

  Widget _buildPhotoPreview() {
    return Container(
      child: Wrap(
        spacing: 8.0,  // Horizontal space between items
        runSpacing: 8.0,  // Vertical space between rows
        children: List.generate(_photoPreviewUrls.length, (index) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  _photoPreviewUrls[index],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _selectedPhotos.removeAt(index);
                      _photoPreviewUrls.removeAt(index);
                    });
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> saveFacility() async {
    if (!_formKey.currentState!.validate()) return;

    User? user = FirebaseAuth.instance.currentUser;
    String? userName = user?.displayName ?? 'Unknown User';
    List<String> uploadedImageUrls = [];

    setState(() {
      isLoading = true;
    });

    try {
      if (_selectedPhotos.isNotEmpty) {
        print('Starting image upload...');

        uploadedImageUrls = await _uploadPhotos();

      } else {
        print('No image bytes available for upload.');
      }

      if (widget.isEditing['isEditing']) {
        print('Editing facility...');
        String? facilityId = widget.isEditing['id']?['id'];
        if (facilityId == null) throw Exception('No facility ID found.');

        if (widget.isEditing['data']['images'] != null) {
          print('Deleting old images...');
          for (var oldImage in widget.isEditing['data']['images']) {
            await FirebaseStorage.instance.refFromURL(oldImage).delete();
          }
        }

        await FirebaseFirestore.instance
            .collection('facilities')
            .doc(facilityId)
            .update({
          'name': facilityNameController.text,
          'description': descriptionController.text,
          'category': selectedCategory,
          'building': selectedBuilding,
          'contact_details': {
            'contact_email': emailController.text,
            'contact_number': contactNumberController.text,
          },
          'position': GeoPoint(
              widget.selectedPin.latitude, widget.selectedPin.longitude),
          'edited_by': userName,
          'updated_at': DateTime.now(),
          'images': uploadedImageUrls,
          'Visibility': isVisible,
        });

        toastification.show(
          context: context,
          title: const Text('Facility successfully updated!'),
          type: ToastificationType.success,
        );
      } else {
        print('Adding new facility...');
        await FirebaseFirestore.instance.collection('facilities').add({
          'name': facilityNameController.text,
          'description': descriptionController.text,
          'category': selectedCategory,
          'building': selectedBuilding,
          'contact_details': {
            'contact_email': emailController.text,
            'contact_number': contactNumberController.text,
          },
          'position': GeoPoint(
              widget.selectedPin.latitude, widget.selectedPin.longitude),
          'added_by': userName,
          'created_at': DateTime.now(),
          'updated_at': DateTime.now(),
          'images': uploadedImageUrls,
          'Visibility': isVisible,
        });

        toastification.show(
          context: context,
          title: const Text('Facility successfully added!'),
          type: ToastificationType.success,
        );
      }
      widget.onCancel();
    } catch (e) {
      toastification.show(
        context: context,
        title: const Text('Failed to save facility!'),
        type: ToastificationType.error,
      );
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


    // if there is a temptData, set the values of the fields
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print(widget.isEditing['data']['images']);

    if (widget.isEditing['isEditing'] == true) {
      // If isEditing is available, populate the form fields
      setState(() {
        facilityNameController.text =
            widget.isEditing['data']['name']; // string
        descriptionController.text =
            widget.isEditing['data']['description']; // string
        // schedules = widget.isEditing['data']['openHours']; // list
        selectedCategory =
            widget.isEditing['data']['category']; // string (drop dowm)
        selectedBuilding =
            widget.isEditing['data']['building']; // string (drop down)
        emailController.text = widget.isEditing['data']['email']; // string
        contactNumberController.text =
            widget.isEditing['data']['number']; // string
        // save the network image to the imageBytes

        // imageBytes = widget.isEditing['data']['images']; // image
      });
    } else {
      // If temptData is available, populate the form fields
      if (widget.temptData != null) {
        setState(() {
          facilityNameController.text =
              widget.temptData?['facilityName']; // string
          descriptionController.text =
              widget.temptData?['description']; // string
          schedules = widget.temptData?['openHours']; // list
          selectedCategory =
              widget.temptData?['category']; // string (drop dowm)
          selectedBuilding =
              widget.temptData?['building']; // string (drop down)
          emailController.text = widget.temptData?['contactNumber']; // string
          contactNumberController.text =
              widget.temptData?['contactNumber']; // string
          imageBytes = widget.temptData?['image']; // image
        });
      }
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
          width: 430,
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
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, left: 20, right: 20, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          widget.isEditing['isEditing']
                              ? 'Updating ${widget.isEditing['data']['name']}'
                              : 'New Facility',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 0, 84, 153),
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 5),
                      Text(
                          widget.isEditing['isEditing']
                              ? 'Update facility to the map'
                              : 'Add a new facility to the map',
                          style: const TextStyle(
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
                                  Icon(FontAwesomeIcons.circleInfo,
                                      size: 18,
                                      color: Color.fromARGB(255, 8, 118, 207)),
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
                                    border: OutlineInputBorder()),
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
                                    border: OutlineInputBorder()),
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

                        // Contact details
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(FontAwesomeIcons.phone,
                                      size: 18,
                                      color: Color.fromARGB(255, 8, 118, 207)),
                                  SizedBox(width: 7),
                                  Text('Contact Details',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w100,
                                      )),
                                ],
                              ),
                              const SizedBox(height: 20),
                              //add validation
                              TextFormField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                    hintText: 'Email',
                                    isDense: true,
                                    border: OutlineInputBorder()),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: contactNumberController,
                                decoration: const InputDecoration(
                                    hintText: 'Contact Number',
                                    isDense: true,
                                    border: OutlineInputBorder()),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a number';
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
                                  Icon(FontAwesomeIcons.gear,
                                      size: 18,
                                      color: Color.fromARGB(255, 8, 118, 207)),
                                  SizedBox(width: 7),
                                  Text('Operational Details',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w100,
                                      )),
                                ],
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
                                hint: const Text('Select a category'),
                                decoration: const InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder()),
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
                              const SizedBox(height: 20),
                              const Text('Open Hours',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  )),
                              OpenHoursForm(
                                openHours: schedules,
                                onSave: (value) {
                                  setState(() {
                                    schedules = value;
                                  });
                                },
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
                                  Icon(FontAwesomeIcons.mapPin,
                                      size: 18,
                                      color: Color.fromARGB(255, 8, 118, 207)),
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
                                decoration: const InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder()),
                                hint: const Text('Select a building'),
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
                                onPressed: _isUploading ? null : _pickImages,
                                child: const Text('Upload Image'),
                              ),
                              // Display all the images in a carousel
                               if (_photoPreviewUrls.isNotEmpty) 
                              Column(
                                children: [
                                  _buildPhotoPreview(),
                                ],
                              ),
                              // if (imageBytes.isEmpty &&
                              //     widget.isEditing['isEditing'])
                              //   SizedBox(
                              //     height: 100,
                              //     child: ListView.builder(
                              //       scrollDirection: Axis.horizontal,
                              //       itemCount: widget
                              //           .isEditing['data']['images'].length,
                              //       itemBuilder: (context, index) {
                              //         return Padding(
                              //           padding:
                              //               const EdgeInsets.only(right: 10),
                              //           child: Image.network(
                              //             widget.isEditing['data']['images']
                              //                 [index],
                              //             width: 100,
                              //             height: 100,
                              //             fit: BoxFit.cover,
                              //           ),
                              //         );
                              //       },
                              //     ),
                              //   ),
                              // if (imageBytes.isNotEmpty)
                              //   SizedBox(
                              //     height: 100,
                              //     child: ListView.builder(
                              //       scrollDirection: Axis.horizontal,
                              //       itemCount: imageBytes.length,
                              //       itemBuilder: (context, index) {
                              //         return Padding(
                              //           padding:
                              //               const EdgeInsets.only(right: 10),
                              //           child: Image.memory(
                              //             imageBytes[index]!,
                              //             width: 100,
                              //             height: 100,
                              //             fit: BoxFit.cover,
                              //           ),
                              //         );
                              //       },
                              //     ),
                              //   ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  Map<String, dynamic> formData = {
                                    'facilityName': facilityNameController.text,
                                    'description': descriptionController.text,
                                    'openHours': schedules,
                                    'category': selectedCategory,
                                    'building': selectedBuilding,
                                    'contactEmail': emailController.text,
                                    'contactNumber':
                                        contactNumberController.text,
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Checkbox(
                                value: isVisible,
                                onChanged: (value) {
                                  setState(() {
                                    isVisible = value ?? true;
                                  });
                                },
                                activeColor: Colors.black,
                              ),
                              Text('Visible to others'),
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
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                const Color.fromARGB(
                                                    255, 160, 160, 160)),
                                      ),
                                      child: const Text('Cancel',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ))),
                                  const SizedBox(width: 10),
                                  // store in firebase
                                  TextButton(
                                    style: const ButtonStyle(
                                      fixedSize: WidgetStatePropertyAll(
                                          Size(100, 35)),
                                      backgroundColor:
                                          WidgetStatePropertyAll(
                                        Color.fromARGB(255, 44, 97, 138),
                                      ),
                                    ),
                                    onPressed: () async {
                                      // Call the saveFacility function
                                      await saveFacility();
                                    },
                                    child: const Text(
                                      'Submit',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isLoading)
                              Container(
                                color: Colors.black.withOpacity(0.5),
                                child: const Center(
                                  child: CircularProgressIndicator(),
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
