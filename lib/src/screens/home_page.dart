import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:uni_camp/src/components/facility_modal.dart';
// import 'package:uni_camp/src/components/map_legend.dart';
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

  // Markers
  List<Map<String, dynamic>> markerData = [
    // Existing markers
    {
      "position": const LatLng(7.072033, 125.613094),
      "title": "Roxas Night Market Davao",
      "description": "A lot of Food stalls when its night time.",
      "contact_details": "09672009871",
      "category": "Food",
      "building": "Finster",
      "image": "https://picsum.photos/890/320?random=1", // Random image from Lorem Picsum
      "open_hours": "6:00 PM - 12:00 AM",
    },
    {
      "position": const LatLng(7.071500, 125.614000),
      "title": "Emergency Room",
      "description": "Emergency Room.",
      "contact_details": "09672009871",
      "category": "Safety",
      "building": "Community Center of the First Companions",
      "image": "https://picsum.photos/890/320?random=2", // Random image from Lorem Picsum
      "open_hours": "None",
    },
    // New markers with random images
    {
      "position": const LatLng(7.073000, 125.609500),
      "title": "Café Davao",
      "description": "A cozy café to enjoy local coffee.",
      "contact_details": "09671012345",
      "category": "Food",
      "building": "Roxas Café Building",
      "image": "https://picsum.photos/890/320?random=3", // Random image from Lorem Picsum
      "open_hours": "8:00 AM - 10:00 PM",
    },
    {
      "position": const LatLng(7.072700, 125.610800),
      "title": "Tech Hub",
      "description": "A place for tech enthusiasts and innovators.",
      "contact_details": "09671023456",
      "category": "Work",
      "building": "Innovation Center",
      "image": "https://picsum.photos/890/320?random=4", // Random image from Lorem Picsum
      "open_hours": "9:00 AM - 6:00 PM",
    },
    {
      "position": const LatLng(7.070800, 125.608200),
      "title": "Health Clinic",
      "description": "A local health clinic offering basic medical services.",
      "contact_details": "09671034567",
      "category": "Health",
      "building": "Community Health Center",
      "image": "https://picsum.photos/890/320?random=5", // Random image from Lorem Picsum
      "open_hours": "8:00 AM - 5:00 PM",
    },
    {
      "position": const LatLng(7.071200, 125.616500),
      "title": "Art Gallery",
      "description": "Local art gallery showcasing student work.",
      "contact_details": "09671045678",
      "category": "Art",
      "building": "Roxas Art Center",
      "image": "https://picsum.photos/890/320?random=6", // Random image from Lorem Picsum
      "open_hours": "10:00 AM - 7:00 PM",
    },
    {
      "position": const LatLng(7.073500, 125.617000),
      "title": "Library",
      "description": "A quiet library for studying and reading.",
      "contact_details": "09671056789",
      "category": "Study",
      "building": "Roxas Library",
      "image": "https://picsum.photos/890/320?random=7", // Random image from Lorem Picsum
      "open_hours": "8:00 AM - 9:00 PM",
    },
  ];

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
      showAllFacilities = true;
      
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
      floatingActionButton: !newLocation ? FloatingActionButton.small(
        backgroundColor: Colors.white,
        onPressed: () => setState(() {
          newLocation = !newLocation;
        }),
        child: const Icon(Icons.add, color: Colors.black,)
      ): null,
      body: SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Stack(
        children: [

          FlutterMap(
            options: MapOptions(
              initialCenter: initialPosition,
              initialZoom: 18.0,
              cameraConstraint: CameraConstraint.contain(bounds:
                LatLngBounds(
                  const LatLng(7.074980053311773, 125.61920470410469),
                  const LatLng(7.068990339917043, 125.6072999884711)
                ),
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
                }else if (searchInput.isEmpty) {
                  setState(() {
                    showAllFacilities = false;
                  });
                }else{

                }
              },
            ),
            mapController: _animatedMapController.mapController,
            children: [
              TileLayer(
                tileProvider: CancellableNetworkTileProvider(),
                urlTemplate: "https://cartodb-basemaps-a.global.ssl.fastly.net/rastertiles/voyager_nolabels/{z}/{x}/{y}.png",
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
                                    color: isSelected ? Colors.blue : Colors.red,
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
                              Text('Selected Pin', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w100),),
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

          // MapLegend(),

          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                showAllFacilities ? LeftModal(
                  facilities: markerData,
                  searchQuery: searchInput,
                  setFacility: (data) => setState(() {
                    selectedPin = data;
                    searchInput = '';
                    showAllFacilities = false;
                    _animatedMapController.animateTo(dest: data['position'], zoom: 19.0);
                  }),
                ) : const SizedBox.shrink(),

                selectedPin != null
                  ? FacilityModal(
                      selectedPin: selectedPin,
                      children: const [],
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

          if (newLocation) RightModal(
            onCancel: () => setState(() {
              temptData = null;
              selectedCoordinates =  const LatLng(0, 0);
              newLocation = false;
            }),
            onSelectPin: (data) => setState(() {
              isSelecting = true;
              newLocation = false;
              showAllFacilities = false;
              savePin = selectedPin;
              selectedPin = null;

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
