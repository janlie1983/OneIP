import '../../domain/models/checklist_progress_model.dart';
import '../../domain/models/permit_item_model.dart';
import '../../domain/models/permit_template_model.dart';
import '../../domain/models/user_checklist_model.dart';
import '../../domain/repositories/permit_checklist_repository.dart';
import '../datasources/permit_checklist_remote_datasource.dart';

class PermitChecklistRepositoryImpl implements PermitChecklistRepository {
  final PermitChecklistRemoteDatasource _ds;

  PermitChecklistRepositoryImpl(this._ds);

  @override
  Future<List<PermitTemplate>> getTemplates() => _ds.getTemplates();

  @override
  Future<List<PermitItem>> getItemsByTemplate(String templateId) =>
      _ds.getItemsByTemplate(templateId);

  @override
  Future<List<UserChecklist>> getUserChecklists(String userId) =>
      _ds.getUserChecklists(userId);

  @override
  Future<UserChecklist> createChecklist({
    required String userId,
    required String templateId,
    required String projectName,
    String? companyName,
    String? province,
  }) =>
      _ds.createChecklist(
        userId: userId,
        templateId: templateId,
        projectName: projectName,
        companyName: companyName,
        province: province,
      );

  @override
  Future<void> deleteChecklist(String checklistId) =>
      _ds.deleteChecklist(checklistId);

  @override
  Future<List<ChecklistProgress>> getProgress(String checklistId) =>
      _ds.getProgress(checklistId);

  @override
  Future<void> upsertProgress(ChecklistProgress progress) =>
      _ds.upsertProgress(progress);

  @override
  Future<void> updateChecklistStatus(String checklistId, String status) =>
      _ds.updateChecklistStatus(checklistId, status);
}
