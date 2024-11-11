import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:uni_camp/src/components/left_modal.dart';
import 'package:uni_camp/src/components/map_legend.dart';
import 'package:latlong2/latlong.dart';
import 'package:uni_camp/src/components/search.dart';
import 'package:uni_camp/src/components/top_bar.dart';
import 'package:uni_camp/src/data/polygons_data.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uni_camp/src/screens/signin_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final LatLng initialPosition = const LatLng(7.072033, 125.613094);
  List<Polygon> polygons = getPolygons();

  List<Map<String, dynamic>> markerData = [
    {
      "position": const LatLng(7.072033, 125.613094),
      "title": "Pin 1",
      "description": "This is the first pin."
    },
    {
      "position": const LatLng(7.071500, 125.614000),
      "title": "Pin 2",
      "description": "This is the second pin."
    },
  ];

  Map<String, dynamic>? selectedPin;
  bool newLocation = false;

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

  @override
  Widget build(BuildContext context) {
    final User? user = firebaseAuth.currentUser;
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => setState(() {
          newLocation = !newLocation;
        }),
        child: const Icon(Icons.add),
      ),
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
            ),
            children: [
              TileLayer(
                urlTemplate: "https://cartodb-basemaps-a.global.ssl.fastly.net/rastertiles/voyager_nolabels/{z}/{x}/{y}.png",
              ),
              PolygonLayer(polygons: polygons),
              MarkerLayer(
                markers: markerData.map((data) {
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
                }).toList(),
              ),
            ],
          ),

          MapLegend(),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              selectedPin != null ?
                LeftModal(
                  selectedPin: selectedPin,
                  children: [
                    const SizedBox(height: 5,),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Search(),
                    ),
                    const SizedBox(height: 20,),
                    Text(
                      selectedPin!["title"],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(selectedPin!["description"]),
                  ]
                )
              :
                const Padding(
                  padding: EdgeInsets.only(top: 15, left: 15),
                  child: Search(),
                ),
              const SizedBox(width: 5,),
              const TopBar(children: [Text('Sample', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),)])
            ],
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

        ],
      ),
    ),
    );
  }
}
