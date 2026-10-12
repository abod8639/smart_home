import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/dashboard_repository.dart';
import '../../data/repositories/dashboard_repository_impl.dart';

part 'send_hardware_command_usecase.g.dart';

/// Use case for dispatching commands to local IoT hardware (ESP32 / Matter).
class SendHardwareCommandUseCase {
  final DashboardRepository repository;

  SendHardwareCommandUseCase(this.repository);

  /// Dispatches an ESP32 command.
  Future<void> sendEsp32Command(
    String path, {
    String method = 'POST',
    Map<String, dynamic>? data,
  }) async {
    await repository.sendEsp32Command(path, method: method, data: data);
  }

  /// Dispatches an on/off command to a Matter node and endpoint.
  Future<void> toggleMatterDevice(int nodeId, int endpointId, bool isOn) async {
    await repository.toggleMatterDevice(nodeId, endpointId, isOn);
  }
}

/// Provider for accessing [SendHardwareCommandUseCase].
@riverpod
SendHardwareCommandUseCase sendHardwareCommandUseCase(Ref ref) {
  return SendHardwareCommandUseCase(ref.watch(dashboardRepositoryProvider));
}
