enum TransportRouteType {
  brt,
  subway,
  bus,
  water,
}

class TransportRoute {
  final TransportRouteType type;
  final int index;
  final List<List<int>> fareMatrix;
  final Set<int> stations;

  const TransportRoute({
    required this.type,
    required this.index,
    required this.fareMatrix,
    required this.stations,
  });
}
