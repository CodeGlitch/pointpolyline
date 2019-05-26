import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GooglePolylineMap extends StatefulWidget {
  GooglePolylineMap({Key key}) : super(key: key);

  @override
  _GooglePolylineMapState createState() => _GooglePolylineMapState();
}

class _GooglePolylineMapState extends State<GooglePolylineMap> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        iconTheme: new IconThemeData(color: Colors.white),
        title: new Text(
          "",
          style: new TextStyle(color: Colors.white),
        ),
      ),
      body: new Container(child: googleMapPolylineBuilder()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String resposta = "";
          for (LatLng item in coordsPoints) {
            resposta = resposta +
                "{lat:" +
                item.latitude.toString() +
                ",lng:" +
                item.longitude.toString() +
                "},";
          }
          resposta =
              resposta.replaceRange(resposta.length - 1, resposta.length, "") + "@zoom:" + ((zoom > 20) ? "20" : zoom.toInt().toString());// + "@center:" + target.latitude.toString() + "," + target.longitude.toString()
          Navigator.pop(context, resposta);
        },
        child: Icon(Icons.save),
      ),
    );
  }

  List<LatLng> coordsPoints = new List();
  double zoom = 6;
  //LatLng target = LatLng(38.503259517928484, -28.15218164062503);

  Widget googleMapPolylineBuilder() {
    CameraPosition _cposition = CameraPosition(
      target: LatLng(38.503259517928484, -28.15218164062503),
      zoom: 6.0,
    );

    Set<Polyline> _lines = {};
    _lines.add(Polyline(
        polylineId:
            PolylineId("1"),
        color: Colors.redAccent,
        points: coordsPoints));

    return Container(
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
          polylines: _lines,
          onCameraMove: (value) {
            zoom = value.zoom;
            //target = value.target;
          },
          onTap: (value) {
            setState(() {
              coordsPoints.add(LatLng(value.latitude, value.longitude));
            });
          },
        ));
  }
}
