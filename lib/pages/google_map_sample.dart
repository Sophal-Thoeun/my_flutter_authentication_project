import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment_auth_maps/config/palette.dart';
import 'package:flutter_assignment_auth_maps/pages/export_pages.dart';
import 'package:flutter_assignment_auth_maps/service_provider/provider.dart';
import 'package:flutter_assignment_auth_maps/widgets/menu_item.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_assignment_auth_maps/repos/map_repo.dart' as mapRepo;
import 'package:provider/provider.dart';

class GoogleMapSample extends StatefulWidget {
  @override
  State<GoogleMapSample> createState() => GoogleMapSampleState();
}

class GoogleMapSampleState extends State<GoogleMapSample> {
  Map<PolylineId, Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];
  PolylinePoints _polylinePoints = PolylinePoints();
  String _googleAPIKey = "AIzaSyBmcDHtRfB5b6STcp4RoG1APEX6pKM5L0c";

//Phnom Penh International Airpot
  LatLng _destination = LatLng(11.5760, 104.9231);

  Set<Marker> _markers = Set<Marker>();

  Future _getPolyline() async {
    Position pos = await mapRepo.getCurrentPosition();
    PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
      _googleAPIKey,
      PointLatLng(pos.latitude, pos.longitude),
      PointLatLng(_destination.latitude, _destination.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly123");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: _polylineCoordinates);
    _polylines[id] = polyline;
    setState(() {});
  }

  Completer<GoogleMapController> _controller = Completer();

  CameraPosition? _initLocation;

  Future<Set<Marker>> _initMarkers(Position position) async {
    final Uint8List byteIcon = await mapRepo.getBytesFromAsset(
        'assets/icons/current location.png', 50);
    final icon = BitmapDescriptor.fromBytes(byteIcon);
    List<Marker> markers = <Marker>[];
    final marker = Marker(
      markerId: MarkerId(position.toString()),
      infoWindow: InfoWindow(
          title: "Your current Location",
          snippet: "You're here",
          onTap: () {
            print("tapped ${position.latitude}, ${position.longitude}");
          }),
      position: LatLng(position.latitude, position.longitude),
      icon: icon,
    );
    markers.add(marker);
    return markers.toSet();
  }

  _initMap() async {
    Position position = await mapRepo.getCurrentPosition();

    _initLocation = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 17,
    );

    _markers = await _initMarkers(position);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  bool _polylineDrawing = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: _buildDrawer,
      appBar: _buildAppBar,
      body: _buildBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildCurrentLocationButton(),
    );
  }

  Drawer get _buildDrawer {
    final gmailLogInProvider =
        Provider.of<GmailSignInService>(context, listen: false);
    final googleSiginProvider =
        Provider.of<GoogleSignInService>(context, listen: false);
    final facebookSiginProvider =
        Provider.of<FacebookSignInService>(context, listen: false);

    return Drawer(
      child: DrawerHeader(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: Palette.scaffold,
        ),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child:
                      gmailLogInProvider.firebaseAuth.currentUser!.photoURL ==
                              null
                          ? CircleAvatar(
                              maxRadius: 40.0,
                              child: Icon(
                                Icons.person,
                                size: 40.0,
                              ),
                            )
                          : CircleAvatar(
                              maxRadius: 40.0,
                              backgroundImage: NetworkImage(gmailLogInProvider
                                  .firebaseAuth.currentUser!.photoURL
                                  .toString()),
                            ),
                ),
                const SizedBox(height: 20.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: gmailLogInProvider
                                  .firebaseAuth.currentUser!.displayName ==
                              null
                          ? null
                          : Text(
                              '${gmailLogInProvider.firebaseAuth.currentUser!.displayName!.toUpperCase()}',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    Text(
                      '${gmailLogInProvider.firebaseAuth.currentUser!.email}',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            const Divider(height: 2.0, color: Colors.blueGrey),
            MenuItem(
              iconData: Icons.logout,
              title: 'Logout',
              iconColor: Colors.black,
              textColor: Colors.black,
              onPressed: () async {
                // await facebookSiginProvider.logout(context);
                // await googleSiginProvider.logout();
                await gmailLogInProvider.logout();
                gmailLogInProvider.logout();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SigninPage(),
                  ),
                );
              },
            ),
            const Divider(height: 2.0, color: Colors.black12),
            MenuItem(
              iconData: Icons.settings,
              title: 'About',
              iconColor: Colors.black,
              textColor: Colors.black,
              onPressed: () {},
            ),
            const Divider(height: 2.0, color: Colors.black12),
          ],
        ),
      ),
    );
  }

  AppBar get _buildAppBar {
    return AppBar(
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      centerTitle: true,
      backgroundColor: Palette.scaffold,
      title: Text(
        "Map Sample",
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        IgnorePointer(
          ignoring: _polylineDrawing,
          child: IconButton(
            onPressed: () async {
              setState(() {
                _polylineDrawing = true;
                _polylineCoordinates.clear();
              });
              await _getPolyline();
              setState(() {
                _polylineDrawing = false;
              });
            },
            icon: _polylineDrawing
                ? CircularProgressIndicator(
                    color: Colors.red,
                  )
                : Icon(Icons.drive_eta),
          ),
        ),
      ],
    );
  }

  bool _cameraLoading = false;

  _buildCurrentLocationButton() {
    return IgnorePointer(
      ignoring: _cameraLoading,
      child: FloatingActionButton(
        child: _cameraLoading
            ? CircularProgressIndicator(
                color: Colors.red,
              )
            : Icon(Icons.person_pin),
        onPressed: () async {
          setState(() {
            _cameraLoading = true;
          });
          final GoogleMapController controller = await _controller.future;
          mapRepo.getCurrentCameraPosition().then((cameraPosition) {
            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {
              _cameraLoading = false;
            });
          });
        },
      ),
    );
  }

  Widget get _buildBody {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: Colors.grey[100],
            alignment: Alignment.center,
          ),
          _buildGoogleMaps,
          _buildDestinationPoint,
          _buildDestinationPin,
        ],
      ),
    );
  }

  Widget get _buildDestinationPoint {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.deepOrange,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget get _buildDestinationPin {
    return Container(
      alignment: Alignment.topCenter,
      width: 100,
      height: 120,
      child: IconButton(
        onPressed: () {
          _alertDialog();
        },
        icon: Icon(
          CupertinoIcons.location_solid,
          size: 50,
          color: Colors.deepOrange,
        ),
      ),
    );
  }

  void _alertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Mark a destination point"),
          content: Text("Do you want to mark your destination point here?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.save_alt),
              label: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Widget get _buildGoogleMaps {
    if (_initLocation == null) {
      return Text("Maps is loading...");
    } else {
      return GoogleMap(
        markers: _markers,
        mapType: MapType.normal,
        polylines: Set<Polyline>.of(_polylines.values),
        initialCameraPosition: _initLocation!,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          mapRepo.getCurrentCameraPosition().then((cameraPosition) {
            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
          });
        },
        onCameraMove: (CameraPosition position) {
          _destination = position.target;
        },
      );
    }
  }
}
