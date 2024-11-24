import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:uni_camp/src/components/facility_modal.dart';
import 'package:uni_camp/src/ui/map_legend.dart';
import 'package:latlong2/latlong.dart';
import 'package:uni_camp/src/components/left_modal.dart';
import 'package:uni_camp/src/components/right_modal.dart';
import 'package:uni_camp/src/components/search.dart';
import 'package:uni_camp/src/data/polygons_data.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uni_camp/src/screens/signin_page.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final LatLng initialPosition = const LatLng(7.072033, 125.613094);
  final TextEditingController _searchController = TextEditingController();
  late final _animatedMapController = AnimatedMapController(vsync: this);
  List<Polygon> polygons = getPolygons();

  // temporary form data for new location
  Map<String, dynamic>? temptData;
  // the currently selected pin data (ito yung left modal)
  Map<String, dynamic>? selectedPin;
  // this is used to temporarily store the selected blue pin data if the user wants to add a new location
  Map<String, dynamic>? savePin;
  // right modal
  bool newLocation = false;
  // the coordinates of the new selected location
  LatLng selectedCoordinates = const LatLng(0, 0);
  // is selecting a new location, if true, the user can click on the map to select a new location
  bool isSelecting = false;
  // show all facilities
  bool showAllFacilities = false;
  // searchInput
  String searchInput = '';
  // tempt data for searchInput
  String temptSearchInput = '';
  // is editing
  Map<String, dynamic> isEditing = {'isEditing': false, 'data': {}};
  // Markers
  List<Map<String, dynamic>> markerData = [
    // {
    //   "position": const LatLng(7.0715, 125.6125),
    //   "added_by": "John Doe",
    //   "building": "Main Building",
    //   "category": "Classroom",
    //   "description": "This is a classroom",
    //   "name": "Room 101",
    //   "email": "random@gmail.com",
    //   "number": "09123456789",
    //   "openHours": {
    //     'Monday': '8:00 AM - 5:00 PM',
    //     'Tuesday': '8:00 AM - 5:00 PM',
    //     'Wednesday': '8:00 AM - 5:00 PM',
    //     'Thursday': '8:00 AM - 5:00 PM',
    //     'Friday': '8:00 AM - 5:00 PM',
    //     'Saturday': '8:00 AM - 5:00 PM',
    //     'Sunday': 'Closed',
    //   },
    //   "timestamp": Timestamp(1633056000, 0),
    //   "created_at": Timestamp(1633056000, 0),
    //   "updated_at": Timestamp(1633056000, 0),
    //   "images": [
    //     "https://ol-content-api.global.ssl.fastly.net/sites/default/files/styles/scale_and_crop_center_890x320/public/2023-01/addu-banner.jpg?itok=ZP3cNDCL",
    //     "https://ol-content-api.global.ssl.fastly.net/sites/default/files/styles/scale_and_crop_center_890x320/public/2023-01/addu-banner.jpg?itok=ZP3cNDCL",
    //     "https://ol-content-api.global.ssl.fastly.net/sites/default/files/styles/scale_and_crop_center_890x320/public/2023-01/addu-banner.jpg?itok=ZP3cNDCL",
    //   ],
    // },
  ];

  @override
  void initState() {
    super.initState();
    fetchMarkerData();
  }

  Future<void> fetchMarkerData() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('facilities').get();
      final List<Map<String, dynamic>> fetchedData =
          querySnapshot.docs.map((doc) {
        final data = doc.data();
        final selectedPin = data['selectedPin'];
        final contactDetails = data['contact_details'] ?? {};

        // final latitude = selectedPin != null && selectedPin['latitude'] != null
        //     ? selectedPin['latitude']
        //     : 0.0;
        // final longitude =
        //     selectedPin != null && selectedPin['longitude'] != null
        //         ? selectedPin['longitude']
        //         : 0.0;

        final double latitude;
        final double longitude;

        if (selectedPin != null &&
            selectedPin['latitude'] != null &&
            selectedPin['longitude'] != null) {
          latitude = selectedPin['latitude'];
          longitude = selectedPin['longitude'];
        } else if (data['position'] != null && data['position'] is GeoPoint) {
          final geoPoint = data['position'] as GeoPoint;
          latitude = geoPoint.latitude;
          longitude = geoPoint.longitude;
        } else {
          latitude = 0.0;
          longitude = 0.0;
        }

        final position = LatLng(latitude, longitude);

        return {
          "position": position,
          "added_by": data['added by'] ?? "Unknown",
          "building": data['building'] ?? "Unknown",
          "category": data['category'] ?? "Unknown",
          "description": data['description'] ?? "No description available",
          "name": data['name'] ?? 'Unknown',
          "email": contactDetails['contact_email'] ?? "no contacts available",
          "number": contactDetails['contact_number'] ?? "no contacts available",
          "openHours": data['openHours'] ?? data['open_hours'] ?? "Not specified",
          "images": data['images'] as List<dynamic>,
          "timestamp": data['timestamp'] ?? "No timestamp available",
          "created_at": data['created_at'] ?? "No created at available",
          "updated_at": data['updated_at'] ?? "No updated at available",
        };
      }).toList();

      setState(() {
        markerData = fetchedData;
      });
    } catch (error) {
      print("Error fetching marker data: $error");
    }
  }

  void _onMarkerTap(Map<String, dynamic> pinData) {
    setState(() {
      selectedPin = pinData;
    });
  }

  Future<void> signOut(BuildContext context) async {
    await firebaseAuth.signOut();
    await GoogleSignIn().signOut();
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }

  void _onMapTapped(LatLng coordinates) {
    setState(() {
      selectedCoordinates = coordinates;
      isSelecting = false;
      newLocation = true;
      selectedPin = savePin;

      toastification.show(
        context: context,
        title: const Text('Location Clicked!'),
        style: ToastificationStyle.flatColored,
        type: ToastificationType.success,
        alignment: Alignment.topCenter,
        autoCloseDuration: const Duration(seconds: 3),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = firebaseAuth.currentUser;
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: !newLocation
          ? FloatingActionButton.small(
              backgroundColor: Colors.white,
              onPressed: () => setState(() {
                    newLocation = !newLocation;
                  }),
              child: const Icon(
                Icons.add,
                color: Colors.black,
              ))
          : null,
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: initialPosition,
                initialZoom: 18.0,
                cameraConstraint: CameraConstraint.contain(
                  bounds: LatLngBounds(
                      const LatLng(7.074980053311773, 125.61920470410469),
                      const LatLng(7.068990339917043, 125.6072999884711)),
                ),
                onTap: isSelecting
                    ? (tapPosition, point) {
                        _onMapTapped(point);
                      }
                    : (tapPosition, point) {
                        setState(() {
                          selectedPin = null;
                        });
                        if (selectedPin != null) {
                          setState(() {
                            selectedPin = null;
                          });
                        } else if (searchInput == '') {
                          setState(() {
                            showAllFacilities = false;
                          });
                        }
                      },
              ),
              mapController: _animatedMapController.mapController,
              children: [
                TileLayer(
                  tileProvider: CancellableNetworkTileProvider(),
                  urlTemplate:
                      "https://cartodb-basemaps-a.global.ssl.fastly.net/rastertiles/voyager_nolabels/{z}/{x}/{y}.png",
                ),
                PolygonLayer(polygons: polygons),
                MarkerLayer(
                  markers: !isSelecting
                      ? [
                          ...markerData.map((data) {
                            bool isSelected = selectedPin == data;
                            return Marker(
                              point: data["position"],
                              width: 60,
                              height: 60,
                              child: GestureDetector(
                                onTap: () => _onMarkerTap(data),
                                child: AnimatedScale(
                                  scale: isSelected ? 1.1 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: Transform.scale(
                                    scale: isSelected ? 1.1 : 1.0,
                                    alignment: Alignment.bottomCenter,
                                    child: Icon(
                                      Icons.location_pin,
                                      color:
                                          isSelected ? Colors.blue : Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          // Add selectedCoordinates if it exists
                          Marker(
                            point: selectedCoordinates,
                            width: 100,
                            height: 60,
                            child: const Column(
                              children: [
                                Text(
                                  'Selected Pin',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w100),
                                ),
                                Icon(
                                  Icons.location_pin,
                                  color: Colors.green,
                                  size: 40,
                                ),
                              ],
                            ),
                          ),
                        ]
                      : [],
                ),
              ],
            ),
            MapLegend(),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  showAllFacilities
                      ? LeftModal(
                          facilities: markerData,
                          searchQuery: searchInput,
                          searchController: _searchController,
                          setFacility: (data) => setState(() {
                            selectedPin = data;
                            searchInput = '';
                            showAllFacilities = false;
                            _animatedMapController.animateTo(
                                dest: data['position'], zoom: 19.0);
                          }),
                        )
                      : const SizedBox.shrink(),
                  selectedPin != null
                      ? FacilityModal(
                          selectedPin: selectedPin,
                          isEditing: (value) {
                            setState(() {
                              newLocation = true;
                              selectedCoordinates = selectedPin!['position'];
                              isEditing = {'isEditing': true, 'data': value};
                            });
                          },
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${user?.displayName}'),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(user?.photoURL ?? ''),
                          radius: 40,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () => signOut(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (newLocation)
              RightModal(
                isEditing: isEditing,
                onCancel: () => setState(() {
                  temptData = null;
                  isEditing = {'isEditing': false, 'data': {}};
                  selectedCoordinates = const LatLng(0, 0);
                  newLocation = false;
                  searchInput = temptSearchInput;
                  if (searchInput != '') {
                    showAllFacilities = true;
                  }
                }),
                onSelectPin: (data) => setState(() {
                  isSelecting = true;
                  newLocation = false;
                  showAllFacilities = false;
                  savePin = selectedPin;
                  selectedPin = null;
                  temptSearchInput = searchInput;
                  temptData = data;
                  // toast, please select a location
                  toastification.show(
                    context: context,
                    title: const Text('Please click on a Location!'),
                    type: ToastificationType.info,
                    style: ToastificationStyle.flatColored,
                    alignment: Alignment.topCenter,
                    autoCloseDuration: const Duration(seconds: 5),
                  );
                }),
                selectedPin: selectedCoordinates,
                temptData: temptData,
              ),
            Positioned(
              top: 10,
              left: 15,
              child: Search(
                searchController: _searchController,
                gotTapped: () {
                  setState(() {
                    showAllFacilities = true;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    showAllFacilities = true;
                    searchInput = value;
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
