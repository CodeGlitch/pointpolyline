import 'dart:async';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'Controlos/googlepolylinemap.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final apiKey = "<APIKEY>";
  LatLng point;
  String polyline;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        iconTheme: new IconThemeData(color: Colors.white),
        title: new Text(
          "pointpolyline",
          style: new TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
          bottom: true,
          top: true,
          child: SingleChildScrollView(
              padding: EdgeInsets.all(10.0),
              child: new Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      new Container(
                          alignment: Alignment.topLeft,
                          padding: new EdgeInsets.only(top: 5.0, bottom: 5.0),
                          child: new Text(
                            "Point",
                            style: new TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Padding(
                        padding: new EdgeInsets.only(left: 20.0),
                      ),
                      IconButton(
                          icon: new Icon(Icons.edit_location),
                          iconSize: 32,
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return Scaffold(
                                body: Container(
                                  child: getNewMapPointItem(),
                                ),
                              );
                            }));
                          }),
                      Padding(
                        padding: new EdgeInsets.only(left: 20.0),
                      ),
                      IconButton(
                        icon: new Icon(Icons.gps_fixed),
                        iconSize: 32,
                        onPressed: () {
                          getLocation().then((value) {
                            setState(() {
                              point =
                                  new LatLng(value.latitude, value.longitude);
                            });
                          });
                        },
                      ),
                    ],
                  ),
                  getMapPointItem(),
                  Row(
                    children: <Widget>[
                      new Container(
                          alignment: Alignment.topLeft,
                          padding: new EdgeInsets.only(top: 5.0, bottom: 5.0),
                          child: new Text(
                            "Polyline",
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      Padding(
                        padding: new EdgeInsets.only(left: 20.0),
                      ),
                      IconButton(
                          icon: new Icon(Icons.edit_location),
                          iconSize: 32,
                          onPressed: () {
                            _navigateAndDisplayGooglePolylineMap(context);
                          }),
                    ],
                  ),
                  getMapPolygonItem(),
                ],
              ))),
    );
  }

  _navigateAndDisplayGooglePolylineMap(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call
    // Navigator.pop on the Selection Screen!
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GooglePolylineMap()),
    );
    if (result != null) {
      setState(() {
        polyline = result;
      });
    }
  }

  Future<LocationData> getLocation() async {
    try {
      LocationData currentLocation = await new Location().getLocation();
      return currentLocation;
    } catch (e) {
      return null;
    }
  }

  Widget getMapPointItem() {
    if (point == null) {
      return Text("");
    } else {
      return Column(
        children: <Widget>[
          Text("lat: " +
              point.latitude.toString() +
              " lon: " +
              point.longitude.toString()),
          Container(
              height: 280.0,
              child: RaisedButton(
                child: Image.network(
                  'https://maps.googleapis.com/maps/api/staticmap?center=' +
                      point.latitude.toString() +
                      "," +
                      point.longitude.toString() +
                      "&zoom=15&size=300x300&maptype=hybrid&markers=color:red%7C" +
                      point.latitude.toString() +
                      "," +
                      point.longitude.toString() +
                      "&key=" +
                      apiKey,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return Scaffold(
                      body: Container(
                        child: getNewMapPointItem(),
                      ),
                    );
                  }));
                },
              )),
        ],
      );
    }
  }

  Widget getNewMapPointItem() {
    Set<Marker> _markers = {};
    CameraPosition _cposition;
    if (point == null) {
      _cposition = CameraPosition(
        target: LatLng(38.503259517928484, -28.15218164062503),
        zoom: 6.0,
      );
    } else {
      _markers.add(Marker(
        markerId: MarkerId("1"),
        position: point,
        icon: BitmapDescriptor.defaultMarker,
      ));
      _cposition = CameraPosition(
        target: point,
        zoom: 15,
      );
    }
    return new Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          iconTheme: new IconThemeData(color: Colors.white),
          title: new Text(
            "",
            style: new TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              compassEnabled: true,
              scrollGesturesEnabled: true,
              rotateGesturesEnabled: true,
              zoomGesturesEnabled: true,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              tiltGesturesEnabled: false,
              initialCameraPosition: _cposition,
              mapType: MapType.hybrid,
              markers: _markers,
              onTap: (value) {
                setState(() {
                  point = new LatLng(value.latitude, value.longitude);
                });
                Navigator.pop(context);
              },
            )));
  }

  Widget getMapPolygonItem() {
    if (polyline == null) {
      return Text("");
    } else {
      List<String> locInfo = polyline.split("@zoom:");
      List<String> coords = locInfo[0].split("{lat:");
      String stringCoords = locInfo[0]
          .toString()
          .replaceAll("{lat:", "|")
          .replaceAll(",lng:", ",")
          .replaceAll("},", "")
          .replaceAll("}", "");
      if (coords.length > 2) {
        String a = coords[coords.length - 1]
            .replaceAll(",lng:", ",")
            .replaceAll("},", "")
            .replaceAll("}", "");
        String b = coords[1]
            .replaceAll(",lng:", ",")
            .replaceAll("},", "")
            .replaceAll("}", "");
        if (a != b) {
          stringCoords = stringCoords + "|" + b;
        }
      }
      String url = "https://maps.googleapis.com/maps/api/staticmap?center=" +
          getCentralGeoCoordinate(stringCoords) +
          "&zoom=" +
          locInfo[1] +
          "&path=fillcolor:0xC73C3C|color:0x0000FF|weight:3" +
          stringCoords +
          "&size=300x300&maptype=hybrid&key=" +
          apiKey;
      return Column(
        children: <Widget>[
          Container(
            height: 280.0,
            child: Image.network(
              url,
            ),
          ),
        ],
      );
    }
  }

  String getCentralGeoCoordinate(String stringCoords) {
    //https://stackoverflow.com/questions/6671183/calculate-the-center-point-of-multiple-latitude-longitude-coordinate-pairs
    /*if (geoCoordinates.Count == 1)
        {
            return geoCoordinates.Single();
        }*/

    double x = 0;
    double y = 0;
    double z = 0;

    List<String> coords = stringCoords.split("|");
    for (String geoCoordinate in coords) {
      if (geoCoordinate.isNotEmpty) {
        List<String> coord = geoCoordinate.split(",");
        var latitude = double.parse(coord[0]) * pi / 180;
        var longitude = double.parse(coord[1]) * pi / 180;

        x += cos(latitude) * cos(longitude);
        y += cos(latitude) * sin(longitude);
        z += sin(latitude);
      }
    }

    var total = coords.length - 1;

    x = x / total;
    y = y / total;
    z = z / total;

    var centralLongitude = atan2(y, x);
    var centralSquareRoot = sqrt(x * x + y * y);
    var centralLatitude = atan2(z, centralSquareRoot);

    return (centralLatitude * 180 / pi).toString() +
        "," +
        (centralLongitude * 180 / pi).toString();
  }
}
