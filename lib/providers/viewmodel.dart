import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karakuri_agent/models/service_config.dart';
import 'package:karakuri_agent/providers/config_storage_provider.dart';
import 'package:karakuri_agent/viewmodels/service_config_screen_viewmodel.dart';
import 'package:karakuri_agent/viewmodels/service_settings_screen_viewmodel.dart';
import 'package:karakuri_agent/viewmodels/talk_screen_viewmodel.dart';

final talkScreenViewmodelProvider = Provider.autoDispose
    .family<TalkScreenViewmodel, (String, String)>((ref, params) {
  final configStorage = ref.watch(configStorageProvider);
  final viewModel =
      TalkScreenViewmodel(ref, params.$1, params.$2, configStorage);
  Future.microtask(() async {
    await viewModel.build();
  });
  ref.onDispose(() {
    viewModel.dispose();
  });
  return viewModel;
});

final serviceSettingsScreenViewmodelProvider = Provider.autoDispose((ref) {
  final configStorage = ref.watch(configStorageProvider);
  final viewModel = ServiceSettingsScreenViewmodel(ref, configStorage);
  Future.microtask(() async {
    await viewModel.build();
  });
  ref.onDispose(() {
    viewModel.dispose();
  });
  return viewModel;
});

final serviceConfigScreenViewmodelProvider = Provider.autoDispose
    .family<ServiceConfigScreenViewmodel, ServiceConfig?>((ref, param) {
  return ServiceConfigScreenViewmodel(ref, serviceConfig: param);
});
