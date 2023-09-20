import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Currentlocation extends StatefulWidget {
  const Currentlocation({Key? key}) : super(key: key);

  @override
  State<Currentlocation> createState() => _CurrentlocationState();
}

class _CurrentlocationState extends State<Currentlocation> {
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition googleplex =
      CameraPosition(target: LatLng(21.170240, 72.831062), zoom: 14);
  final List<Marker> marker = <Marker>[
    Marker(
        markerId: MarkerId('1'),
        position: LatLng(21.170240, 72.831062),
        infoWindow: InfoWindow(title: 'the title of marker'))
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center());
  }
}
