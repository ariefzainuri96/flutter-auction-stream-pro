import 'package:hive_ce_flutter/hive_flutter.dart';
import '../cores/config/flavor_config.dart';
import '../cores/constants/hives/hive_boxes.dart';
import 'entity/auth_data.dart';
import 'hive_registrar.g.dart';

class HiveHelper {
  static initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
    await Hive.openBox<AuthData>(HiveBoxes.auth);
    await Hive.openBox<String>(HiveBoxes.savedOfflineDataKey);

    _getSavedAuthData();
  }

  static void _getSavedAuthData() {
    Box<AuthData> box = Hive.box<AuthData>(HiveBoxes.auth);
    AuthData? authData = box.get(HiveBoxes.auth);

    if (authData != null) {
      FlavorConfig.instance?.values.token = authData.token ?? '';
      FlavorConfig.instance?.values.userId = authData.userId ?? 0;
      FlavorConfig.instance?.values.role = authData.role ?? '';
      FlavorConfig.instance?.values.password = authData.password ?? '';
    }
  }

  static Future<void> clearData() async {
    await saveUserToBox(AuthData());
  }

  static Future<void> clearOfflineData() async {
    Box<String> box = Hive.box(HiveBoxes.savedOfflineDataKey);
    var listSavedOfflineDataKey = box.values.toList();

    final clearKodeDaerahTasks = <Future<void>>[];

    for (var i = 0; i < listSavedOfflineDataKey.length; i++) {
      // clearKodeDaerahTasks.add(saveKodeDaerah(listSavedOfflineDataKey[i], []));
    }

    await Future.wait(clearKodeDaerahTasks);

    await box.clear();
  }

  static saveUserToBox(AuthData authData) async {
    Box<AuthData> box = Hive.box<AuthData>(HiveBoxes.auth);

    FlavorConfig.instance?.values.token = authData.token ?? '';
    FlavorConfig.instance?.values.userId = authData.userId ?? 0;
    FlavorConfig.instance?.values.role = authData.role ?? '';
    FlavorConfig.instance?.values.password = authData.password ?? '';

    await box.put(HiveBoxes.auth, authData);
  }

  // static Future<void> saveData(AddData data) async {
  //   Box<AddData> box = Hive.box(HiveBoxes.addData);
  //   await box.add(data);
  // }

  // static Future<void> saveAllData(List<AddData> data) async {
  //   Box<AddData> box = Hive.box(HiveBoxes.addData);
  //   await box.clear();
  //   await box.addAll(data);
  // }

  // static Future<void> removeData(int index) async {
  //   Box<AddData> box = Hive.box(HiveBoxes.addData);
  //   await box.deleteAt(index);
  // }

  // static List<AddData> getData() {
  //   Box<AddData> box = Hive.box(HiveBoxes.addData);
  //   return box.values.toList();
  // }

  static Future<void> saveOfflineDataKey(String key) async {
    Box<String> box = Hive.box(HiveBoxes.savedOfflineDataKey);
    await box.add(key);
  }

  static List<String> getOfflineDataKey() {
    Box<String> box = Hive.box(HiveBoxes.savedOfflineDataKey);
    return box.values.toList();
  }
}
