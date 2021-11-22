import 'package:map_launcher/map_launcher.dart';

class MapUtil {
  void openMap({required double lat, required double long}) async{

    Coords coords = Coords(lat, long);

    if ((await MapLauncher.isMapAvailable(MapType.google)) == true) {

      await MapLauncher.showDirections(
        mapType: MapType.google,
        destination: coords,
      );
    }
    else{
      throw 'Could not launch map';
    }
  }
}
