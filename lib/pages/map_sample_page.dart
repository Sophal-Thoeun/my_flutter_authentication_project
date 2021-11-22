import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_assignment_auth_maps/repos/map_repo.dart' as mapRepo;

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Map<PolylineId, Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];
  PolylinePoints _polylinePoints = PolylinePoints();
  String _googleAPIKey = "AIzaSyBmcDHtRfB5b6STcp4RoG1APEX6pKM5L0c";

//Wat Phnom
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
      appBar: _buildAppBar,
      body: _buildBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildCurrentLocationButton(),
    );
  }

  AppBar get _buildAppBar {
    return AppBar(
      backgroundColor: Colors.red,
      title: Text("Map Sample"),
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
                ? CircularProgressIndicator(color: Colors.red)
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
          mapRepo.getCurrentCameraPosition().then(
                (cameraPosition) {
              controller.animateCamera(
                CameraUpdate.newCameraPosition(cameraPosition),
              );
            },
          );
        },
        onCameraMove: (CameraPosition position) {
          _destination = position.target;
        },
      );
    }
  }
}
