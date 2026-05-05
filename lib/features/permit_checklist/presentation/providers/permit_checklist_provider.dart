import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/permit_checklist_remote_datasource.dart';
import '../../data/repositories/permit_checklist_repository_impl.dart';
import '../../domain/models/checklist_progress_model.dart';
import '../../domain/models/permit_item_model.dart';
import '../../domain/models/permit_template_model.dart';
import '../../domain/models/user_checklist_model.dart';
import '../../domain/repositories/permit_checklist_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final permitChecklistRepositoryProvider =
    Provider<PermitChecklistRepository>((ref) {
  return PermitChecklistRepositoryImpl(PermitChecklistRemoteDatasource());
});

final permitTemplatesProvider = FutureProvider<List<PermitTemplate>>((ref) {
  return ref.watch(permitChecklistRepositoryProvider).getTemplates();
});

final checklistItemsProvider =
    FutureProvider.family<List<PermitItem>, String>((ref, templateId) {
  return ref
      .watch(permitChecklistRepositoryProvider)
      .getItemsByTemplate(templateId);
});

final userChecklistsProvider =
    FutureProvider<List<UserChecklist>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref
      .watch(permitChecklistRepositoryProvider)
      .getUserChecklists(user.id);
});

final checklistProgressProvider =
    FutureProvider.family<List<ChecklistProgress>, String>(
        (ref, checklistId) async {
  return ref
      .watch(permitChecklistRepositoryProvider)
      .getProgress(checklistId);
});

final selectedTemplateProvider = StateProvider<PermitTemplate?>((ref) => null);
