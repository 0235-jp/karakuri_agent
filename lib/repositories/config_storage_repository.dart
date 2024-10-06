import 'dart:convert';

import 'package:karakuri_agent/models/agent_config.dart';
import 'package:karakuri_agent/models/service_config.dart';
import 'package:karakuri_agent/services/shared_preference_service.dart';

class ConfigStorageRepository {
  static const String _keyServiceConfig = 'service_configs';
  static const String _keyAgentConfig = 'agent_configs';
  final SharedPreferencesService _service;

  ConfigStorageRepository(this._service);

  Future<void> saveServiceConfigs(List<ServiceConfig> configs) async {
    final jsonList =
        configs.map((config) => jsonEncode(config.toJson())).toList();
    await _service.setStringList(_keyServiceConfig, jsonList);
  }

  Future<List<ServiceConfig>> loadServiceConfigs() async {
    final jsonList = await _service.getStringList(_keyServiceConfig) ?? [];
    return jsonList
        .map((jsonString) => ServiceConfig.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  Future<List<ServiceConfig>> loadTextServiceConfigs() async {
    final jsonList = await _service.getStringList(_keyServiceConfig) ?? [];
    return jsonList
        .map((jsonString) => ServiceConfig.fromJson(jsonDecode(jsonString)))
        .where((config) => config.textConfig != null)
        .toList();
  }

  Future<List<ServiceConfig>> loadSpeechToTextServiceConfigs() async {
    final jsonList = await _service.getStringList(_keyServiceConfig) ?? [];
    return jsonList
        .map((jsonString) => ServiceConfig.fromJson(jsonDecode(jsonString)))
        .where((config) => config.speechToTextConfig != null)
        .toList();
  }

  Future<List<ServiceConfig>> loadTextToSpeechServiceConfigs() async {
    final jsonList = await _service.getStringList(_keyServiceConfig) ?? [];
    return jsonList
        .map((jsonString) => ServiceConfig.fromJson(jsonDecode(jsonString)))
        .where((config) => config.textToSpeechConfig != null)
        .toList();
  }

  Future<void> saveAgentConfigs(List<AgentConfig> configs) async {
    final jsonList =
        configs.map((config) => jsonEncode(config.toJson())).toList();
    await _service.setStringList(_keyAgentConfig, jsonList);
  }

  Future<List<AgentConfig>> loadAgentConfigs() async {
    final jsonList = await _service.getStringList(_keyAgentConfig) ?? [];
    return jsonList
        .map((jsonString) => AgentConfig.fromJson(jsonDecode(jsonString)))
        .toList();
  }
}
