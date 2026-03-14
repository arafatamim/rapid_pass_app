enum TransportRouteType {
  brt,
  subway,
  bus,
  water,
}

final class TransportRoute {
  final TransportRouteType type;
  final int index;
  final Fare fare;
  final Set<int> stations;

  const TransportRoute({
    required this.type,
    required this.index,
    required this.fare,
    required this.stations,
  });
}

final class Fare {
  final List<List<int>>? fareMatrix;
  final double rapidPassDiscount;
  final double cashDiscount;

  const Fare({
    this.fareMatrix,
    this.rapidPassDiscount = 1,
    this.cashDiscount = 1,
  });

  int? getFare(int from, int to) {
    return fareMatrix?[from][to];
  }
}
