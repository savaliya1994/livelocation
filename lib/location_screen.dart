import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String? currentaddress;
  Position? currentposition;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            currentposition!.latitude, currentposition!.longitude)
        .then((List<Placemark> placemark) {
      Placemark place = placemark[0];
      setState(() {
        currentaddress =
            '${place.street},${place.subLocality},${place.locality}-${place.postalCode},${place.country}';
      });
    }).catchError((e) {
      print(e);
    });
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) {
      setState(() {
        currentposition = value;
      });
      _getAddressFromLatLng(currentposition!);
    }).catchError((e) {
      print(e);
    });
  }

  Loaddata() async {
    _getCurrentPosition().then((value) {
      print(currentposition!.latitude.toString());
      print(currentposition!.longitude.toString());
    });
    marker.add(Marker(
        markerId: MarkerId('2'),
        position: LatLng(currentposition!.latitude, currentposition!.longitude),
        infoWindow: InfoWindow(title: '$currentaddress')));
    CameraPosition cameraposition = CameraPosition(
        target: LatLng(currentposition!.latitude, currentposition!.longitude),
        zoom: 17);
    final GoogleMapController controlr = await _controller.future;
    controlr.animateCamera(CameraUpdate.newCameraPosition(cameraposition));
    setState(() {});
  }

  @override
  void initState() {
    Loaddata();
    super.initState();
  }

  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition googleplex =
      CameraPosition(target: LatLng(21.170240, 72.831062), zoom: 17);

  final List<Marker> marker = <Marker>[
    Marker(
        markerId: MarkerId('1'),
        position: LatLng(21.170240, 72.831062),
        infoWindow: InfoWindow(title: 'surat'))
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Location Page")),
      body: GoogleMap(
        onTap: (argument) {},
        mapType: MapType.normal,
        initialCameraPosition: googleplex,
        markers: Set<Marker>.of(marker),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Loaddata();
        },
        child: Icon(Icons.location_searching),
      ),
      // SafeArea(
      //   child: Center(
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         Text('LAT: ${currentposition?.latitude ?? ""}'),
      //         Text('LNG: ${currentposition?.longitude ?? ""}'),
      //         Text('ADDRESS: \n${currentaddress ?? ""}'),
      //         SizedBox(height: 32),
      //         ElevatedButton(
      //           onPressed: _getCurrentPosition,
      //           child: Text("Get Current Location"),
      //         )
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
