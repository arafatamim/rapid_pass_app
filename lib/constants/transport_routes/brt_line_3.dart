import 'package:rapid_pass_info/constants/fare_matrices/brt_line_3.dart';
import 'package:rapid_pass_info/models/transport_route.dart';

class BrtLine3Station {
  static const shibbari = 0;
  static const gazipurJunction = 1;
  static const boardBazar = 2;
  static const collegeGate = 3;
  static const airport = 4;
  static const farmgate = 5;
  static const shahbag = 6;
  static const gulistan = 7;
}

const brtLine3 = TransportRoute(
  index: 2,
  type: TransportRouteType.brt,
  fare: Fare(fareMatrix: brtLine3FareMatrix),
  stations: {
    BrtLine3Station.shibbari,
    BrtLine3Station.gazipurJunction,
    BrtLine3Station.boardBazar,
    BrtLine3Station.collegeGate,
    BrtLine3Station.airport,
    BrtLine3Station.farmgate,
    BrtLine3Station.shahbag,
    BrtLine3Station.gulistan,
  },
);
