import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/environment_model.dart';

part 'environment_local_datasource.g.dart';

/// Local/in-memory data source for broadcasting and holding environment telemetry.
class EnvironmentLocalDatasource {
  EnvironmentModel _current = const EnvironmentModel();
  final _controller = StreamController<EnvironmentModel>.broadcast();

  EnvironmentModel get current => _current;

  Stream<EnvironmentModel> get stream => _controller.stream;

  void update(EnvironmentModel Function(EnvironmentModel) updater) {
    _current = updater(_current);
    _controller.add(_current);
  }

  void dispose() {
    _controller.close();
  }
}

/// Riverpod provider for [EnvironmentLocalDatasource].
@Riverpod(keepAlive: true)
EnvironmentLocalDatasource environmentLocalDatasource(Ref ref) {
  final ds = EnvironmentLocalDatasource();
  ref.onDispose(ds.dispose);
  return ds;
}
