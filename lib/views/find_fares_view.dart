import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rapid_pass_info/constants/transport_routes/transport_routes.dart';
import 'package:rapid_pass_info/helpers/transport_route_localizations.dart';
import 'package:rapid_pass_info/models/transport_route.dart';

class StationEntry {
  final int routeIndex;
  final int stationIndex;
  final TransportRouteType routeType;

  const StationEntry({
    required this.routeIndex,
    required this.stationIndex,
    required this.routeType,
  });

  String getStationName(BuildContext context) {
    return TransportRouteLocalizations.of(context)
        .translate(routeIndex, stationIndex);
  }

  IconData getStationIcon() {
    return switch (routeType) {
      TransportRouteType.brt => Icons.directions_bus,
      TransportRouteType.subway => Icons.subway,
      TransportRouteType.bus => Icons.directions_bus,
      TransportRouteType.water => Icons.directions_boat,
    };
  }
}

class FindFaresView extends StatefulWidget {
  const FindFaresView({super.key});

  @override
  State<FindFaresView> createState() => _FindFaresViewState();
}

class _FindFaresViewState extends State<FindFaresView> {
  List<DropdownMenuEntry<StationEntry>> _originEntries = [];
  List<DropdownMenuEntry<StationEntry>> _destinationEntries = [];

  StationEntry? _selectedOrigin;
  StationEntry? _selectedDestination;

  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  List<DropdownMenuEntry<StationEntry>> getStationEntries([int? routeIndex]) {
    Set<StationEntry> stations = {};

    if (routeIndex != null) {
      // find only the stations for the selected route
      final route = transportRoutes[routeIndex];
      if (route == null) {
        return [];
      }
      final stationIndices = route.stations;
      for (final index in stationIndices) {
        stations.add(
          StationEntry(
            routeIndex: route.index,
            stationIndex: index,
            routeType: route.type,
          ),
        );
      }
    } else {
      for (final route in transportRoutes.entries) {
        final routeIndex = route.key;
        final routeValue = route.value;
        final stationIndices = routeValue.stations;
        for (final index in stationIndices) {
          stations.add(
            StationEntry(
              routeIndex: routeIndex,
              stationIndex: index,
              routeType: routeValue.type,
            ),
          );
        }
      }
    }

    final List<DropdownMenuEntry<StationEntry>> dropdownMenuEntries =
        stations.map(
      (station) {
        return DropdownMenuEntry(
          value: station,
          label: station.getStationName(context),
          leadingIcon: Icon(station.getStationIcon()),
          trailingIcon: Text(
            TransportRouteLocalizations.of(context)
                .translateRouteName(station.routeIndex),
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Theme.of(context).hintColor),
          ),
        );
      },
    ).toList();

    dropdownMenuEntries.sort((a, b) {
      return a.label.compareTo(b.label);
    });

    return dropdownMenuEntries;
  }

  @override
  void initState() {
    super.initState();
    /* not required if its displayed in drawer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.registerRefreshCallback(() async {
        setState(() {
          _selectedOrigin = null;
          _selectedDestination = null;
          _destinationController.clear();
          _originController.clear();
        });
      });
    });
    */
  }

  @override
  void didChangeDependencies() {
    _originEntries = getStationEntries();
    _destinationEntries = getStationEntries();
    super.didChangeDependencies();
  }

  Widget _buildLeftIcons() {
    return Column(
      children: [
        const Icon(Icons.circle_outlined),
        const SizedBox(height: 6),
        Icon(
          Icons.more_vert_sharp,
          color: Theme.of(context).hintColor,
        ),
        const SizedBox(height: 6),
        Icon(
          Icons.location_pin,
          color: Theme.of(context).colorScheme.error,
        )
      ],
    );
  }

  Widget _buildDropdowns() {
    return Expanded(
      child: Column(
        children: [
          // origin dropdown
          DropdownMenu<StationEntry>(
            controller: _originController,
            hintText: AppLocalizations.of(context)!.chooseOrigin,
            expandedInsets: EdgeInsets.zero,
            dropdownMenuEntries: _originEntries,
            onSelected: (entry) {
              if (entry != null) {
                setState(
                  () {
                    _destinationEntries = getStationEntries(entry.routeIndex);
                    _selectedOrigin = entry;

                    if (_selectedDestination != null &&
                        _selectedDestination!.routeIndex != entry.routeIndex) {
                      // clear destination if it's not in the same route
                      _selectedDestination = null;
                      _destinationController.clear();
                    }
                  },
                );
              }
            },
          ),
          const SizedBox(height: 8),
          // destination dropdown
          DropdownMenu<StationEntry>(
            hintText: AppLocalizations.of(context)!.chooseDestination,
            enabled: _selectedOrigin != null,
            expandedInsets: EdgeInsets.zero,
            dropdownMenuEntries: _destinationEntries,
            controller: _destinationController,
            onSelected: (entry) {
              if (entry != null) {
                setState(() {
                  _selectedDestination = entry;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Row(
      children: [
        _buildLeftIcons(),
        const SizedBox(width: 8),
        _buildDropdowns(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _buildForm(),
        ),
        const SizedBox(height: 16),
        if (_selectedOrigin != null && _selectedDestination != null)
          Card(
            color: Theme.of(context).colorScheme.onInverseSurface,
            child: FareCalculator(
              origin: _selectedOrigin!,
              destination: _selectedDestination!,
            ),
          ),
      ],
    );
  }
}

class FareCalculator extends StatelessWidget {
  final StationEntry origin;
  final StationEntry destination;

  const FareCalculator({
    super.key,
    required this.origin,
    required this.destination,
  });

  Widget _buildTitle(BuildContext context) {
    return Text(
      "${TransportRouteLocalizations.of(context).translate(
        origin.routeIndex,
        origin.stationIndex,
      )} ⇔ ${TransportRouteLocalizations.of(context).translate(
        destination.routeIndex,
        destination.stationIndex,
      )}",
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Widget _buildRouteName(BuildContext context) {
    return Row(
      children: [
        Icon(
          origin.getStationIcon(),
          color: Theme.of(context).hintColor,
        ),
        const SizedBox(width: 8),
        Text(
          TransportRouteLocalizations.of(context)
              .translateRouteName(origin.routeIndex)
              .toUpperCase(),
          textAlign: TextAlign.left,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: Theme.of(context).hintColor),
        ),
      ],
    );
  }

  Widget _buildFare(BuildContext context, int fare) {
    return Row(
      children: [
        Align(
          alignment: const Alignment(0, -0.3),
          child: Text(
            "৳",
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 20,
                  color: Theme.of(context).hintColor,
                ),
          ),
        ),
        Text(
          "$fare",
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(BuildContext context, String method, int fare) {
    return Row(
      children: [
        Text(method),
        const Spacer(),
        _buildFare(context, fare),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final fare = getFare();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          const SizedBox(height: 8),
          _buildRouteName(context),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          _buildPaymentMethod(
            context,
            AppLocalizations.of(context)!.rapidPass,
            (fare * 0.9).toInt(),
          ),
          _buildPaymentMethod(
            context,
            AppLocalizations.of(context)!.cash,
            fare,
          ),
        ],
      ),
    );
  }

  int getFare() {
    final routeIndex = origin.routeIndex;
    final route = transportRoutes[routeIndex];
    if (route == null) {
      throw Exception("Route not found");
    }

    return route.fareMatrix[origin.stationIndex][destination.stationIndex];
  }
}
