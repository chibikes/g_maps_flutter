import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;

  LatLng _currentLocation = const LatLng(6.4351, 7.5248);
  late PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];

  Map<PolylineId, Polyline> polylines = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: Column(
          children: [
            SizedBox(
              width: 500,
              height: 500,
              child: GoogleMap(
                markers: {
                  Marker(
                      markerId: const MarkerId('myloc'),
                      position: _currentLocation)
                },
                polylines: Set<Polyline>.of(polylines.values),
                buildingsEnabled: false,
                mapType: MapType.normal,
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentLocation,
                  zoom: 11.0,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _getCurrentLocation();
              },
              child: const Text('get current location'),
            ),


            ElevatedButton(
              onPressed: () async {
                await _createPolyLines(
                    _currentLocation.latitude, _currentLocation.longitude, 6.4600, 7.4950);
              },
              child: const Text('draw polylines'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low)
        .then((position) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    });
  }

  _createPolyLines(double startLat, double startLong, double destLat,
      double destLong) async {
    polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        //TODO: if the first five letters of the key is used as keyId for an account how many user accounts are possible and how many
        // keys can be generated for an account?
        '',
        PointLatLng(startLat, startLong),
        PointLatLng(destLat, destLong),
        travelMode: TravelMode.driving, optimizeWaypoints: true);
    if (result.points.isNotEmpty) {

      for (var element in result.points) {
        polylineCoordinates.add(LatLng(element.latitude, element.longitude));
      }
    }

    PolylineId id = const PolylineId('poly');

    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 5);

    setState(() {
      polylines[id] = polyline;
    });
  }
}
