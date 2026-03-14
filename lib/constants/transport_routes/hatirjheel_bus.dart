import 'package:rapid_pass_info/models/transport_route.dart';

class HatirjheelBus {
  static const rampura = 0;
  static const modhubag = 1;
  static const mohanagar = 2;
  static const fdc = 3;
  static const kunipara = 4;
  static const policePlaza = 5;
  static const badda = 6;
  static const bouBazar = 7;
}

const hatirjheelBus = TransportRoute(
  index: 6,
  type: TransportRouteType.bus,
  fare: Fare(),
  stations: {
    HatirjheelBus.rampura,
    HatirjheelBus.modhubag,
    HatirjheelBus.mohanagar,
    HatirjheelBus.fdc,
    HatirjheelBus.kunipara,
    HatirjheelBus.policePlaza,
    HatirjheelBus.badda,
    HatirjheelBus.bouBazar,
  },
);
