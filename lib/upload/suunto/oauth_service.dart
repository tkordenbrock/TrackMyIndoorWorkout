import '../../export/fit/fit_export.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import '../../persistence/secret.dart';
import 'suunto.dart';

class SuuntoService {
  Suunto _suunto = Suunto(SUUNTO_CLIENT_ID, SUUNTO_SECRET);

  Future<bool> login() async {
    return await _suunto.oauth(_suunto.clientId, _suunto.secret);
  }

  Future<bool> hasValidToken() async {
    return await _suunto.hasValidToken();
  }

  Future<int> upload(Activity activity, List<Record> records) async {
    if (records.length <= 0) {
      return 0;
    }

    final exporter = FitExport();
    final file = await exporter.getExport(activity, records, false, false);
    final statusCode = await _suunto.uploadActivity(activity, file, exporter);

    return statusCode;
  }
}
