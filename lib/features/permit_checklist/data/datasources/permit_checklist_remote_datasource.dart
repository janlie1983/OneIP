import '../../../../core/config/supabase_config.dart';
import '../../domain/models/checklist_progress_model.dart';
import '../../domain/models/permit_item_model.dart';
import '../../domain/models/permit_template_model.dart';
import '../../domain/models/user_checklist_model.dart';

class PermitChecklistRemoteDatasource {
  static dynamic get _client => SupabaseConfig.client;

  Future<List<PermitTemplate>> getTemplates() async {
    final data = await _client
        .from('permit_templates')
        .select()
        .order('is_premium')
        .order('estimated_days');
    return (data as List).map((m) => PermitTemplate.fromMap(m)).toList();
  }

  Future<List<PermitItem>> getItemsByTemplate(String templateId) async {
    final data = await _client
        .from('permit_items')
        .select()
        .eq('template_id', templateId)
        .order('sort_order');
    return (data as List).map((m) => PermitItem.fromMap(m)).toList();
  }

  Future<List<UserChecklist>> getUserChecklists(String userId) async {
    final data = await _client
        .from('user_checklists')
        .select()
        .eq('user_id', userId)
        .neq('status', 'archived')
        .order('updated_at', ascending: false);
    return (data as List).map((m) => UserChecklist.fromMap(m)).toList();
  }

  Future<UserChecklist> createChecklist({
    required String userId,
    required String templateId,
    required String projectName,
    String? companyName,
    String? province,
  }) async {
    final data = await _client.from('user_checklists').insert({
      'user_id': userId,
      'template_id': templateId,
      'project_name': projectName,
      'company_name': companyName,
      'province': province,
    }).select().single();
    return UserChecklist.fromMap(data);
  }

  Future<void> deleteChecklist(String checklistId) async {
    await _client
        .from('user_checklists')
        .update({'status': 'archived'})
        .eq('id', checklistId);
  }

  Future<List<ChecklistProgress>> getProgress(String checklistId) async {
    final data = await _client
        .from('checklist_progress')
        .select()
        .eq('checklist_id', checklistId);
    return (data as List).map((m) => ChecklistProgress.fromMap(m)).toList();
  }

  Future<void> upsertProgress(ChecklistProgress progress) async {
    await _client
        .from('checklist_progress')
        .upsert(
          progress.toUpsertMap(),
          onConflict: 'checklist_id,item_id',
        );
  }

  Future<void> updateChecklistStatus(String checklistId, String status) async {
    await _client
        .from('user_checklists')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', checklistId);
  }
}
