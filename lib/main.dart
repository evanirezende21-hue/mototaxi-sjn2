import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MotoTaxiApp());

class MotoTaxiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moto Táxi SJN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: MapaTela(),
    );
  }
}

class MapaTela extends StatefulWidget {
  @override
  _MapaTelaState createState() => _MapaTelaState();
}

class _MapaTelaState extends State<MapaTela> {
  LatLng? minhaLocalizacao;
  final centroSJN = LatLng(-21.539, -43.011);
  String statusGPS = 'Toque no botão pra localizar';

  Future<void> pegarLocalizacao() async {
    setState(() => statusGPS = 'Buscando GPS...');
    
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => statusGPS = 'GPS desativado. Ative nas configurações');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => statusGPS = 'Permissão de GPS negada');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => statusGPS = 'Permissão bloqueada. Libere nas configs do app');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        minhaLocalizacao = LatLng(position.latitude, position.longitude);
        statusGPS = 'Localizado com sucesso!';
      });
    } catch (e) {
      setState(() => statusGPS = 'Erro ao pegar GPS. Usando centro da cidade');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Moto Táxi SJN'),
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: minhaLocalizacao ?? centroSJN,
              zoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mototaxi.sjn',
              ),
              if (minhaLocalizacao != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: minhaLocalizacao!,
                      width: 40,
                      height: 40,
                      builder: (ctx) => Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(statusGPS, style: TextStyle(fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: pegarLocalizacao,
        backgroundColor: Colors.orange,
        icon: Icon(Icons.my_location),
        label: Text('Minha Localização'),
      ),
    );
  }
}
