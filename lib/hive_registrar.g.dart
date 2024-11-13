import 'package:hive_ce/hive.dart';
import 'package:rapid_pass_info/models/rapid_pass.dart';

extension HiveRegistrar on HiveInterface {
  void registerAdapters() {
    registerAdapter(RapidPassAdapter());
    registerAdapter(RapidPassDataAdapter());
  }
}
