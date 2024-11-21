import 'package:rapid_pass_info/constants/fare_matrices/line_6.dart';
import 'package:rapid_pass_info/models/transport_route.dart';

class Line6Station {
  static const uttaraNorth = 0;
  static const uttaraCenter = 1;
  static const uttaraSouth = 2;
  static const pallabi = 3;
  static const mirpur11 = 4;
  static const mirpur10 = 5;
  static const kazipara = 6;
  static const shewrapara = 7;
  static const agargaon = 8;
  static const bijoySarani = 9;
  static const farmgate = 10;
  static const karwanBazar = 11;
  static const shahbagh = 12;
  static const dhakaUniversity = 13;
  static const bangladeshSecretariat = 14;
  static const motijheel = 15;
  static const kamalapur = 16;
}

const line6 = TransportRoute(
  index: 5,
  type: TransportRouteType.subway,
  fareMatrix: fareMatrix,
  stations: {
    Line6Station.uttaraNorth,
    Line6Station.uttaraCenter,
    Line6Station.uttaraSouth,
    Line6Station.pallabi,
    Line6Station.mirpur11,
    Line6Station.mirpur10,
    Line6Station.kazipara,
    Line6Station.shewrapara,
    Line6Station.agargaon,
    Line6Station.bijoySarani,
    Line6Station.farmgate,
    Line6Station.karwanBazar,
    Line6Station.shahbagh,
    Line6Station.dhakaUniversity,
    Line6Station.bangladeshSecretariat,
    Line6Station.motijheel,
    Line6Station.kamalapur,
  },
);
