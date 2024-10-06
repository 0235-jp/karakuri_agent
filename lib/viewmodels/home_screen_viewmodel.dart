import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karakuri_agent/models/agent_config.dart';
import 'package:karakuri_agent/repositories/config_storage_repository.dart';

class HomeScreenViewmodel {
  final AutoDisposeProviderRef _ref;
  final ConfigStorageRepository _configStorage;
  final AutoDisposeStateProvider<bool> initializedProvider =
      StateProvider.autoDispose<bool>((ref) => false);
  late AutoDisposeStateProvider<List<AgentConfig>> agentConfigsProvider;

  HomeScreenViewmodel(this._ref, this._configStorage);

  Future<void> build() async {
    final agentConfig = await _configStorage.loadAgentConfigs();
    agentConfigsProvider = StateProvider.autoDispose<List<AgentConfig>>((ref) => agentConfig);
    _ref.watch(initializedProvider.notifier).state = true;
  }

  void dispose() {
  }

  Future<void> saveAgentConfig(AgentConfig config) async {
    final serviceConfigNotifer = _ref.read(agentConfigsProvider.notifier);
    final currentConfigs = serviceConfigNotifer.state ?? [];
    final index = currentConfigs.indexWhere((c) => c.id == config.id);
    List<AgentConfig> updatedConfigs;

    if (index != -1) {
      updatedConfigs = List.from(currentConfigs);
      updatedConfigs[index] = config;
    } else {
      updatedConfigs = [
        ...currentConfigs,
        config.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString())
      ];
    }

    serviceConfigNotifer.state = updatedConfigs;
    await _configStorage.saveAgentConfigs(updatedConfigs);
  }

  Future<void> deleteAgentConfig(String configId) async {
    final serviceConfigNotifer = _ref.read(agentConfigsProvider.notifier);
    final currentConfigs = serviceConfigNotifer.state ?? [];
    final updatedConfigs =
        currentConfigs.where((config) => config.id != configId).toList();
    serviceConfigNotifer.state = updatedConfigs;
    await _configStorage.saveAgentConfigs(updatedConfigs);
  }
}
