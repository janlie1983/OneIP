import '../models/checklist_progress_model.dart';
import '../models/permit_item_model.dart';
import '../models/permit_template_model.dart';
import '../models/user_checklist_model.dart';

abstract class PermitChecklistRepository {
  Future<List<PermitTemplate>> getTemplates();
  Future<List<PermitItem>> getItemsByTemplate(String templateId);
  Future<List<UserChecklist>> getUserChecklists(String userId);
  Future<UserChecklist> createChecklist({
    required String userId,
    required String templateId,
    required String projectName,
    String? companyName,
    String? province,
  });
  Future<void> deleteChecklist(String checklistId);
  Future<List<ChecklistProgress>> getProgress(String checklistId);
  Future<void> upsertProgress(ChecklistProgress progress);
  Future<void> updateChecklistStatus(String checklistId, String status);
}
