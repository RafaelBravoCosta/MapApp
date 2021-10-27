import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:projeto/Screens/AddPlace.dart';
import 'package:projeto/helpers/firebase_helper.dart';
import 'package:projeto/widgets/searchbar_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapController mapController;
  bool searchFlag = false;
  final LatLng _center = const LatLng(45.521563, -122.677433);
  final Set<Marker> _markers = {};
  double latitude;
  double longitude;
  String searchAddr;

  _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    context.read<FirebaseHelper>().focusMap = focusMapOnCoordinates;
  }

  // Used to focus the maps current view to the location of the coordinates passed in this function
  // Camera will focus on these latitide & longitude
  // And automatically add a marker on the point
  void focusMapOnCoordinates(latitude, longitude) {
    mapController
        .animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            latitude,
            longitude,
          ),
          zoom: 15,
        ),
      ),
    )
        .then(
      (value) {
        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId('new'),
              icon: BitmapDescriptor.defaultMarkerWithHue(0),
              position: LatLng(
                latitude,
                longitude,
              ),
              onTap: () {
                Navigator.of(context).push(
                  new MaterialPageRoute(
                    builder: (BuildContext context) => new AddPlace(
                      latitude: latitude.toString(),
                      longitude: longitude.toString(),
                    ),
                  ),
                );
              },
            ),
          );
          this.latitude = latitude;
          this.longitude = longitude;
        });
      },
    );
  }

  _onPressed() {
    setState(() {
      searchFlag = !searchFlag;
    });
    print(searchFlag);
  }

  void _onTapped(LatLng argument, context) {
    setState(
      () {
        _markers.add(
          Marker(
              markerId: MarkerId('new'),
              icon: BitmapDescriptor.defaultMarkerWithHue(0),
              position: argument,
              onTap: () {
                Navigator.of(context).push(
                  new MaterialPageRoute(
                    builder: (BuildContext context) => new AddPlace(
                      latitude: latitude.toString(),
                      longitude: longitude.toString(),
                    ),
                  ),
                );
              }),
        );
      },
    );
  }

  searchandNavigate() async {
    List<Location> locations = await locationFromAddress(searchAddr);
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(locations[0].latitude, locations[0].longitude),
          zoom: 10.0,
        ),
      ),
    );
  }

  // Use this function to open the Google Maps app when one of the 2 buttons at the bottom right corner are pressed
  // isDir is used to check if the Direction buttonwas pressed,
  // If it was, open the map app in Navigation mode
  Future<void> _launchUrl(bool isDir, double lat, double lon) async {
    String url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';

    if (isDir) {
      url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon';
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // the 2 buttons at the bottom right corner
  Widget mapToolBar() {
    if (latitude == null || longitude == null) return SizedBox();
    return Row(
      children: [
        FloatingActionButton(
          child: Icon(Icons.map),
          backgroundColor: Colors.blue,
          onPressed: () {
            _launchUrl(false, latitude, longitude);
          },
        ),
        SizedBox(
          width: 10,
        ),
        FloatingActionButton(
          child: Icon(Icons.directions),
          backgroundColor: Colors.blue,
          onPressed: () {
            _launchUrl(true, latitude, longitude);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (searchFlag)
      return FlappySearchBar();
    else {
      return SafeArea(
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              GoogleMap(
                onMapCreated: _onMapCreated,
                compassEnabled: true,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                // Disable the toolbar, we a re using custom toolbar
                mapToolbarEnabled: false,
                onTap: (arguments) {
                  latitude = arguments.latitude;
                  longitude = arguments.longitude;
                  _onTapped(arguments, context);
                },
                markers: _markers,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 11.0,
                ),
              ),
              Positioned(
                top: 30.0,
                right: 15.0,
                left: 15.0,
                child: Container(
                  height: 50.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Enter Address',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                        suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () => searchandNavigate(),
                            iconSize: 30.0)),
                    onChanged: (val) {
                      setState(() {
                        searchAddr = val;
                      });
                    },
                  ),
                ),
              ),
              Positioned(
                child: mapToolBar(),
                right: 0.15 * MediaQuery.of(context).size.width,
                bottom: 15,
              ),
            ],
          ),
        ),
      );
    }
  }
}
