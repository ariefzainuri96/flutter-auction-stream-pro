import 'package:hive_ce/hive.dart';
import 'entity/auth_data.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<AuthData>(),
])
class HiveAdapterConfig {}
