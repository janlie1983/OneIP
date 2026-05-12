import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/constants/vietnam_provinces.dart';
import '../providers/listing_provider.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  final String? editListingId;

  const CreateListingScreen({super.key, this.editListingId});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  int _step = 0;
  String? _savedListingId;
  bool _saving = false;
  Timer? _autoSaveTimer;
  String? _lastSavedAt;

  // Step 1
  String? _assetType;
  String? _province;
  String? _district;
  String? _zoneId;
  String? _region;

  // Step 2
  final _areaCtrl = TextEditingController();
  final _officeAreaCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _floorLoadCtrl = TextEditingController();
  final _floorsCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _powerCtrl = TextEditingController();
  final _dockCtrl = TextEditingController();
  bool _has3Phase = true;
  bool _hasWater = true;
  bool _hasWastewater = false;
  bool _hasFiber = true;
  bool _hasSecurity = true;
  bool _hasCanteen = false;
  bool _hasParking = true;
  bool _hasLoadingDock = false;

  // Step 3
  final _priceUsdCtrl = TextEditingController();
  final _priceVndCtrl = TextEditingController();
  final _minLeaseCtrl = TextEditingController();
  final _availAreaCtrl = TextEditingController();
  bool _isNegotiable = true;
  DateTime? _availableFrom;

  // Step 4
  final _titleCtrl = TextEditingController();
  final _titleEnCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _descEnCtrl = TextEditingController();
  final _contactNameCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _contactEmailCtrl = TextEditingController();
  final _contactZaloCtrl = TextEditingController();

  // Images (placeholder)
  final List<String> _images = [];

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.editListingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_savedListingId != null && _assetType != null && _province != null) {
        _doSave(status: 'draft', showFeedback: false);
      }
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    for (final c in [
      _areaCtrl, _officeAreaCtrl, _heightCtrl, _floorLoadCtrl,
      _floorsCtrl, _yearCtrl, _powerCtrl, _dockCtrl,
      _priceUsdCtrl, _priceVndCtrl, _minLeaseCtrl, _availAreaCtrl,
      _titleCtrl, _titleEnCtrl, _descCtrl, _descEnCtrl,
      _contactNameCtrl, _contactPhoneCtrl, _contactEmailCtrl, _contactZaloCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final listing = await ref
        .read(listingRepositoryProvider)
        .getListingById(widget.editListingId!);
    if (listing == null || !mounted) return;
    setState(() {
      _savedListingId = listing.id;
      _assetType = listing.assetType;
      _province = listing.province;
      _district = listing.district;
      _zoneId = listing.zoneId;
      _region = listing.region;
      _areaCtrl.text = listing.totalAreaM2.toStringAsFixed(0);
      _officeAreaCtrl.text = listing.officeAreaM2?.toStringAsFixed(0) ?? '';
      _heightCtrl.text = listing.clearHeightM?.toStringAsFixed(1) ?? '';
      _floorLoadCtrl.text =
          listing.floorLoadCapacity?.toStringAsFixed(0) ?? '';
      _floorsCtrl.text = listing.numberOfFloors.toString();
      _yearCtrl.text = listing.yearBuilt?.toString() ?? '';
      _powerCtrl.text = listing.powerCapacityKva?.toStringAsFixed(0) ?? '';
      _dockCtrl.text = listing.loadingDockCount?.toString() ?? '';
      _has3Phase = listing.has3PhasePower;
      _hasWater = listing.hasWaterSupply;
      _hasWastewater = listing.hasWastewaterTreatment;
      _hasFiber = listing.hasFiberInternet;
      _hasSecurity = listing.hasSecurity;
      _hasCanteen = listing.hasCanteen;
      _hasParking = listing.hasParking;
      _hasLoadingDock = listing.hasLoadingDock;
      _priceUsdCtrl.text = listing.leasePriceUsd?.toStringAsFixed(0) ?? '';
      _priceVndCtrl.text = listing.leasePriceVnd?.toString() ?? '';
      _minLeaseCtrl.text = listing.minLeaseTermMonths?.toString() ?? '';
      _availAreaCtrl.text = listing.availableAreaM2?.toStringAsFixed(0) ?? '';
      _isNegotiable = listing.isNegotiable;
      _availableFrom = listing.availableFrom;
      _titleCtrl.text = listing.title;
      _titleEnCtrl.text = listing.titleEn ?? '';
      _descCtrl.text = listing.description ?? '';
      _descEnCtrl.text = listing.descriptionEn ?? '';
      _contactNameCtrl.text = listing.contactName ?? '';
      _contactPhoneCtrl.text = listing.contactPhone ?? '';
      _contactEmailCtrl.text = listing.contactEmail ?? '';
      _contactZaloCtrl.text = listing.contactZalo ?? '';
    });
  }

  bool _validateCurrentStep() {
    return switch (_step) {
      0 => _step1Key.currentState?.validate() == true &&
          _assetType != null &&
          _province != null,
      1 => _step2Key.currentState?.validate() == true,
      2 => _step3Key.currentState?.validate() == true,
      3 => _step4Key.currentState?.validate() == true,
      _ => true,
    };
  }

  Map<String, dynamic> _buildPayload({required String status}) {
    return {
      'owner_id': ref.read(currentUserProvider)?.id,
      'asset_type': _assetType,
      'province': _province,
      'district': _district?.isEmpty == true ? null : _district,
      'zone_id': _zoneId,
      'region': _region,
      'title': _titleCtrl.text.trim().isEmpty
          ? '${_assetTypeLabel(_assetType)} - $_province'
          : _titleCtrl.text.trim(),
      'title_en': _titleEnCtrl.text.trim().isEmpty
          ? null
          : _titleEnCtrl.text.trim(),
      'description': _descCtrl.text.trim().isEmpty
          ? null
          : _descCtrl.text.trim(),
      'description_en': _descEnCtrl.text.trim().isEmpty
          ? null
          : _descEnCtrl.text.trim(),
      'total_area_m2': double.tryParse(_areaCtrl.text) ?? 0,
      'office_area_m2': double.tryParse(_officeAreaCtrl.text),
      'clear_height_m': double.tryParse(_heightCtrl.text),
      'floor_load_capacity': double.tryParse(_floorLoadCtrl.text),
      'number_of_floors': int.tryParse(_floorsCtrl.text) ?? 1,
      'year_built': int.tryParse(_yearCtrl.text),
      'power_capacity_kva': double.tryParse(_powerCtrl.text),
      'loading_dock_count': int.tryParse(_dockCtrl.text),
      'has_3_phase_power': _has3Phase,
      'has_water_supply': _hasWater,
      'has_wastewater_treatment': _hasWastewater,
      'has_fiber_internet': _hasFiber,
      'has_security': _hasSecurity,
      'has_canteen': _hasCanteen,
      'has_parking': _hasParking,
      'has_loading_dock': _hasLoadingDock,
      'lease_price_usd': double.tryParse(_priceUsdCtrl.text),
      'lease_price_vnd':
          int.tryParse(_priceVndCtrl.text.replaceAll(',', '')),
      'min_lease_term_months': int.tryParse(_minLeaseCtrl.text),
      'is_negotiable': _isNegotiable,
      'available_area_m2': double.tryParse(_availAreaCtrl.text),
      'available_from':
          _availableFrom?.toIso8601String().split('T').first,
      'contact_name': _contactNameCtrl.text.trim().isEmpty
          ? null
          : _contactNameCtrl.text.trim(),
      'contact_phone': _contactPhoneCtrl.text.trim().isEmpty
          ? null
          : _contactPhoneCtrl.text.trim(),
      'contact_email': _contactEmailCtrl.text.trim().isEmpty
          ? null
          : _contactEmailCtrl.text.trim(),
      'contact_zalo': _contactZaloCtrl.text.trim().isEmpty
          ? null
          : _contactZaloCtrl.text.trim(),
      'images': _images,
      'status': status,
    };
  }

  Future<void> _doSave(
      {required String status, bool showFeedback = true}) async {
    setState(() => _saving = true);
    try {
      final payload = _buildPayload(status: status);
      if (_savedListingId != null) {
        await ref
            .read(listingRepositoryProvider)
            .updateListing(_savedListingId!, payload);
      } else {
        _savedListingId = await ref
            .read(listingRepositoryProvider)
            .createListing(payload);
      }
      ref.invalidate(myListingsProvider);
      final now = TimeOfDay.now();
      setState(() =>
          _lastSavedAt = '${now.hour}:${now.minute.toString().padLeft(2, '0')}');
      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(status == 'draft'
              ? 'Đã lưu nháp lúc $_lastSavedAt'
              : 'Đã gửi duyệt thành công!'),
          backgroundColor:
              status == 'draft' ? AppColors.navy : AppColors.success,
        ));
        if (status == 'pending_review' && mounted) {
          context.go('/my-listings');
        }
      }
    } catch (e) {
      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _assetTypeLabel(String? type) => switch (type) {
        'rbf' => 'Nhà xưởng xây sẵn',
        'rbw' => 'Kho xây sẵn',
        'land' => 'Đất KCN',
        'office' => 'Văn phòng nhà máy',
        _ => 'Bất động sản',
      };

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editListingId != null;
    final role = ref.watch(userRoleProvider);
    if (!role.isSupply) {
      return _RoleGuardScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEdit ? 'Chỉnh sửa listing' : 'Đăng bất động sản',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        leading: BackButton(onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/my-listings');
          }
        }),
        actions: [
          if (_lastSavedAt != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  'Đã lưu $_lastSavedAt',
                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _StepIndicator(current: _step),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: switch (_step) {
                    0 => _Step1(
                        formKey: _step1Key,
                        assetType: _assetType,
                        province: _province,
                        district: _district,
                        zoneId: _zoneId,
                        region: _region,
                        onAssetType: (v) =>
                            setState(() => _assetType = v),
                        onProvince: (v) => setState(() {
                          _province = v;
                          _region = regionForProvince(v ?? '');
                        }),
                        onDistrict: (v) =>
                            setState(() => _district = v),
                        onZone: (id) => setState(() => _zoneId = id),
                      ),
                    1 => _Step2(
                        formKey: _step2Key,
                        areaCtrl: _areaCtrl,
                        officeAreaCtrl: _officeAreaCtrl,
                        heightCtrl: _heightCtrl,
                        floorLoadCtrl: _floorLoadCtrl,
                        floorsCtrl: _floorsCtrl,
                        yearCtrl: _yearCtrl,
                        powerCtrl: _powerCtrl,
                        dockCtrl: _dockCtrl,
                        has3Phase: _has3Phase,
                        hasWater: _hasWater,
                        hasWastewater: _hasWastewater,
                        hasFiber: _hasFiber,
                        hasSecurity: _hasSecurity,
                        hasCanteen: _hasCanteen,
                        hasParking: _hasParking,
                        hasLoadingDock: _hasLoadingDock,
                        onToggle3Phase: (v) =>
                            setState(() => _has3Phase = v),
                        onToggleWater: (v) =>
                            setState(() => _hasWater = v),
                        onToggleWastewater: (v) =>
                            setState(() => _hasWastewater = v),
                        onToggleFiber: (v) =>
                            setState(() => _hasFiber = v),
                        onToggleSecurity: (v) =>
                            setState(() => _hasSecurity = v),
                        onToggleCanteen: (v) =>
                            setState(() => _hasCanteen = v),
                        onToggleParking: (v) =>
                            setState(() => _hasParking = v),
                        onToggleDock: (v) =>
                            setState(() => _hasLoadingDock = v),
                      ),
                    2 => _Step3(
                        formKey: _step3Key,
                        priceUsdCtrl: _priceUsdCtrl,
                        priceVndCtrl: _priceVndCtrl,
                        minLeaseCtrl: _minLeaseCtrl,
                        availAreaCtrl: _availAreaCtrl,
                        isNegotiable: _isNegotiable,
                        availableFrom: _availableFrom,
                        onNegotiable: (v) =>
                            setState(() => _isNegotiable = v),
                        onAvailableFrom: (d) =>
                            setState(() => _availableFrom = d),
                        onPriceUsdChanged: (usd) {
                          final v = double.tryParse(usd);
                          if (v != null) {
                            _priceVndCtrl.text =
                                (v * 24000 / 12).toStringAsFixed(0);
                          }
                        },
                      ),
                    3 => _Step4(
                        formKey: _step4Key,
                        titleCtrl: _titleCtrl,
                        titleEnCtrl: _titleEnCtrl,
                        descCtrl: _descCtrl,
                        descEnCtrl: _descEnCtrl,
                        contactNameCtrl: _contactNameCtrl,
                        contactPhoneCtrl: _contactPhoneCtrl,
                        contactEmailCtrl: _contactEmailCtrl,
                        contactZaloCtrl: _contactZaloCtrl,
                        images: _images,
                        onAddImage: () => setState(() =>
                            _images.add('https://placehold.co/800x600.png')),
                        onRemoveImage: (i) =>
                            setState(() => _images.removeAt(i)),
                      ),
                    _ => const SizedBox.shrink(),
                  },
                ),
              ),
            ),
          ),
          _BottomNav(
            step: _step,
            saving: _saving,
            onBack: _step > 0
                ? () => setState(() => _step--)
                : null,
            onNext: _step < 3
                ? () {
                    if (_validateCurrentStep()) {
                      setState(() => _step++);
                    }
                  }
                : null,
            onSaveDraft: () {
              if (_validateCurrentStep()) {
                _doSave(status: 'draft');
              }
            },
            onSubmit: _step == 3
                ? () {
                    if (_validateCurrentStep()) {
                      _doSave(status: 'pending_review');
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  const _StepIndicator({required this.current});

  static const _steps = [
    ('1', 'Loại & Vị trí'),
    ('2', 'Thông số'),
    ('3', 'Giá & Thời gian'),
    ('4', 'Thông tin'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 1,
                color: Colors.white24,
              ),
            );
          }
          final idx = i ~/ 2;
          final isDone = idx < current;
          final isCurrent = idx == current;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.gold
                      : isDone
                          ? AppColors.success
                          : Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text(
                          _steps[idx].$1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isCurrent ? AppColors.navy : Colors.white70,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _steps[idx].$2,
                style: TextStyle(
                  fontSize: 9,
                  color: isCurrent ? AppColors.gold : Colors.white60,
                  fontWeight:
                      isCurrent ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Bottom Navigation ─────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int step;
  final bool saving;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback onSaveDraft;
  final VoidCallback? onSubmit;

  const _BottomNav({
    required this.step,
    required this.saving,
    this.onBack,
    this.onNext,
    required this.onSaveDraft,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottom > 0 ? bottom : 12),
      child: Row(
        children: [
          if (onBack != null)
            OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navy,
                side: const BorderSide(color: AppColors.navy),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('← Quay lại'),
            ),
          const Spacer(),
          TextButton(
            onPressed: saving ? null : onSaveDraft,
            style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary),
            child: const Text('Lưu nháp'),
          ),
          const SizedBox(width: 8),
          if (onSubmit != null)
            FilledButton(
              onPressed: saving ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.navy),
                    )
                  : const Text('Gửi duyệt'),
            )
          else if (onNext != null)
            FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: const Text('Tiếp theo →'),
            ),
        ],
      ),
    );
  }
}

// ── Step 1: Loại & Vị trí ─────────────────────────────────────────────────────

class _Step1 extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final String? assetType;
  final String? province;
  final String? district;
  final String? zoneId;
  final String? region;
  final ValueChanged<String?> onAssetType;
  final ValueChanged<String?> onProvince;
  final ValueChanged<String?> onDistrict;
  final ValueChanged<String?> onZone;

  const _Step1({
    required this.formKey,
    required this.assetType,
    required this.province,
    required this.district,
    required this.zoneId,
    required this.region,
    required this.onAssetType,
    required this.onProvince,
    required this.onDistrict,
    required this.onZone,
  });

  static const _types = [
    ('rbf', 'Nhà xưởng\nxây sẵn', Icons.factory),
    ('rbw', 'Kho\nxây sẵn', Icons.warehouse),
    ('land', 'Đất KCN', Icons.landscape),
    ('office', 'Văn phòng\nnhà máy', Icons.business),
  ];

  Color _typeColor(String t) => switch (t) {
        'rbf' => const Color(0xFF1B2A4A),
        'rbw' => const Color(0xFF2E7D32),
        'land' => const Color(0xFFF57C00),
        'office' => const Color(0xFF6A1B9A),
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zonesAsync = ref.watch(industrialZoneOptionsProvider);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Loại bất động sản *'),
          if (assetType == null)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Vui lòng chọn loại BĐS',
                  style:
                      TextStyle(color: AppColors.error, fontSize: 12)),
            ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: _types.map((t) {
              final selected = assetType == t.$1;
              return GestureDetector(
                onTap: () => onAssetType(t.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: selected
                        ? _typeColor(t.$1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? _typeColor(t.$1)
                          : AppColors.border,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(t.$3,
                          size: 22,
                          color: selected
                              ? Colors.white
                              : _typeColor(t.$1)),
                      const SizedBox(width: 8),
                      Text(
                        t.$2,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _SectionTitle('Tỉnh / Thành phố *'),
          DropdownButtonFormField<String>(
            key: ValueKey(province),
            initialValue: province,
            decoration: _inputDec('Chọn tỉnh thành'),
            validator: (v) =>
                v == null ? 'Vui lòng chọn tỉnh thành' : null,
            items: kAllProvinces
                .map((p) =>
                    DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 14))))
                .toList(),
            onChanged: onProvince,
          ),
          if (region != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.map, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Vùng: ${switch (region) {
                    'North' => 'Miền Bắc',
                    'Central' => 'Miền Trung',
                    _ => 'Miền Nam',
                  }}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          _SectionTitle('Quận / Huyện'),
          TextFormField(
            initialValue: district,
            decoration: _inputDec('Nhập quận/huyện'),
            onChanged: onDistrict,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          _SectionTitle('Khu công nghiệp (tùy chọn)'),
          zonesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (err, stack) => Text('$err',
                style: const TextStyle(color: AppColors.error)),
            data: (zones) => DropdownButtonFormField<String?>(
              key: ValueKey(zoneId),
              initialValue: zoneId,
              decoration: _inputDec('Chọn KCN (nếu có)'),
              items: [
                const DropdownMenuItem(
                    value: null,
                    child: Text('Không thuộc KCN cụ thể',
                        style: TextStyle(fontSize: 14))),
                ...zones.map((z) => DropdownMenuItem(
                    value: z['id'],
                    child: Text(z['name']!,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis))),
              ],
              onChanged: (v) => onZone(v),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Thông số kỹ thuật ─────────────────────────────────────────────────

class _Step2 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController areaCtrl, officeAreaCtrl, heightCtrl,
      floorLoadCtrl, floorsCtrl, yearCtrl, powerCtrl, dockCtrl;
  final bool has3Phase, hasWater, hasWastewater, hasFiber, hasSecurity,
      hasCanteen, hasParking, hasLoadingDock;
  final ValueChanged<bool> onToggle3Phase, onToggleWater, onToggleWastewater,
      onToggleFiber, onToggleSecurity, onToggleCanteen, onToggleParking,
      onToggleDock;

  const _Step2({
    required this.formKey,
    required this.areaCtrl,
    required this.officeAreaCtrl,
    required this.heightCtrl,
    required this.floorLoadCtrl,
    required this.floorsCtrl,
    required this.yearCtrl,
    required this.powerCtrl,
    required this.dockCtrl,
    required this.has3Phase,
    required this.hasWater,
    required this.hasWastewater,
    required this.hasFiber,
    required this.hasSecurity,
    required this.hasCanteen,
    required this.hasParking,
    required this.hasLoadingDock,
    required this.onToggle3Phase,
    required this.onToggleWater,
    required this.onToggleWastewater,
    required this.onToggleFiber,
    required this.onToggleSecurity,
    required this.onToggleCanteen,
    required this.onToggleParking,
    required this.onToggleDock,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Diện tích'),
          _NumField(ctrl: areaCtrl, label: 'Tổng diện tích (m²) *',
              validator: (v) => (v == null || v.isEmpty) ? 'Bắt buộc' : null),
          _NumField(ctrl: officeAreaCtrl, label: 'Diện tích văn phòng (m²)'),
          const SizedBox(height: 16),
          _SectionTitle('Thông số xây dựng'),
          Row(children: [
            Expanded(child: _NumField(ctrl: heightCtrl, label: 'Chiều cao (m)', decimal: true)),
            const SizedBox(width: 12),
            Expanded(child: _NumField(ctrl: floorLoadCtrl, label: 'Tải trọng sàn (kg/m²)')),
          ]),
          Row(children: [
            Expanded(child: _NumField(ctrl: floorsCtrl, label: 'Số tầng')),
            const SizedBox(width: 12),
            Expanded(child: _NumField(ctrl: yearCtrl, label: 'Năm xây dựng')),
          ]),
          Row(children: [
            Expanded(child: _NumField(ctrl: powerCtrl, label: 'Điện (KVA)')),
            const SizedBox(width: 12),
            Expanded(child: _NumField(ctrl: dockCtrl, label: 'Loading dock (cửa)')),
          ]),
          const SizedBox(height: 20),
          _SectionTitle('Tiện ích & Tính năng'),
          _ToggleRow('Điện 3 pha', has3Phase, onToggle3Phase),
          _ToggleRow('Cấp thoát nước', hasWater, onToggleWater),
          _ToggleRow('Xử lý nước thải', hasWastewater, onToggleWastewater),
          _ToggleRow('Internet cáp quang', hasFiber, onToggleFiber),
          _ToggleRow('An ninh 24/7', hasSecurity, onToggleSecurity),
          _ToggleRow('Căng tin', hasCanteen, onToggleCanteen),
          _ToggleRow('Bãi đỗ xe', hasParking, onToggleParking),
          _ToggleRow('Loading dock', hasLoadingDock, onToggleDock),
        ],
      ),
    );
  }
}

// ── Step 3: Giá & Thời gian ───────────────────────────────────────────────────

class _Step3 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController priceUsdCtrl, priceVndCtrl, minLeaseCtrl,
      availAreaCtrl;
  final bool isNegotiable;
  final DateTime? availableFrom;
  final ValueChanged<bool> onNegotiable;
  final ValueChanged<DateTime?> onAvailableFrom;
  final ValueChanged<String> onPriceUsdChanged;

  const _Step3({
    required this.formKey,
    required this.priceUsdCtrl,
    required this.priceVndCtrl,
    required this.minLeaseCtrl,
    required this.availAreaCtrl,
    required this.isNegotiable,
    required this.availableFrom,
    required this.onNegotiable,
    required this.onAvailableFrom,
    required this.onPriceUsdChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Giá thuê'),
          const Text(
            'Để trống nếu "Liên hệ"',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          _NumField(
            ctrl: priceUsdCtrl,
            label: 'Giá thuê USD/m²/năm',
            decimal: true,
            onChanged: onPriceUsdChanged,
          ),
          _NumField(
            ctrl: priceVndCtrl,
            label: 'Giá thuê VND/m²/tháng (tự chuyển)',
            decimal: true,
          ),
          _ToggleRow('Có thể thương lượng', isNegotiable, onNegotiable),
          const SizedBox(height: 16),
          _SectionTitle('Thời gian & Diện tích'),
          _NumField(ctrl: minLeaseCtrl, label: 'Thời hạn thuê tối thiểu (tháng)'),
          _NumField(ctrl: availAreaCtrl, label: 'Diện tích còn trống (m²)', decimal: true),
          const SizedBox(height: 8),
          _SectionTitle('Ngày có thể bàn giao'),
          GestureDetector(
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 1095)),
              );
              onAvailableFrom(d);
            },
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    availableFrom != null
                        ? '${availableFrom!.day.toString().padLeft(2, '0')}/${availableFrom!.month.toString().padLeft(2, '0')}/${availableFrom!.year}'
                        : 'Chọn ngày bàn giao',
                    style: TextStyle(
                      fontSize: 14,
                      color: availableFrom != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 4: Thông tin & Liên hệ ───────────────────────────────────────────────

class _Step4 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleCtrl, titleEnCtrl, descCtrl, descEnCtrl,
      contactNameCtrl, contactPhoneCtrl, contactEmailCtrl, contactZaloCtrl;
  final List<String> images;
  final VoidCallback onAddImage;
  final ValueChanged<int> onRemoveImage;

  const _Step4({
    required this.formKey,
    required this.titleCtrl,
    required this.titleEnCtrl,
    required this.descCtrl,
    required this.descEnCtrl,
    required this.contactNameCtrl,
    required this.contactPhoneCtrl,
    required this.contactEmailCtrl,
    required this.contactZaloCtrl,
    required this.images,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Tiêu đề & Mô tả'),
          _TextField(ctrl: titleCtrl, label: 'Tiêu đề (Tiếng Việt) *',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null),
          _TextField(ctrl: titleEnCtrl, label: 'Tiêu đề (English)'),
          _TextField(ctrl: descCtrl, label: 'Mô tả (Tiếng Việt) *',
              maxLines: 5,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null),
          _TextField(ctrl: descEnCtrl, label: 'Mô tả (English)', maxLines: 4),
          const SizedBox(height: 16),
          _SectionTitle('Hình ảnh'),
          const Text(
            'Thêm hình ảnh để thu hút người tìm kiếm (tối đa 10 ảnh)',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...images.asMap().entries.map((e) => Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                        image: DecorationImage(
                          image: NetworkImage(e.value),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => onRemoveImage(e.key),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )),
                if (images.length < 10)
                  GestureDetector(
                    onTap: onAddImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.border, style: BorderStyle.solid),
                        color: AppColors.backgroundLight,
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              color: AppColors.textSecondary, size: 28),
                          SizedBox(height: 4),
                          Text('Thêm ảnh',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle('Thông tin liên hệ'),
          _TextField(ctrl: contactNameCtrl, label: 'Tên người liên hệ *',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null),
          _TextField(ctrl: contactPhoneCtrl, label: 'Số điện thoại *',
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null),
          _TextField(ctrl: contactEmailCtrl, label: 'Email *',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Bắt buộc';
                if (!v.contains('@')) return 'Email không hợp lệ';
                return null;
              }),
          _TextField(ctrl: contactZaloCtrl, label: 'Zalo'),
        ],
      ),
    );
  }
}

// ── Reusable form widgets ─────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool decimal;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _NumField({
    required this.ctrl,
    required this.label,
    this.decimal = false,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType:
            TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
              decimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]')),
        ],
        validator: validator,
        onChanged: onChanged,
        decoration: _inputDec(label),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _TextField({
    required this.ctrl,
    required this.label,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: _inputDec(label),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow(this.label, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.navy,
        ),
      ],
    );
  }
}

InputDecoration _inputDec(String hint) => InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );

// ── Role Guard ────────────────────────────────────────────────────────────────

class _RoleGuardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Không có quyền truy cập'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.business_outlined,
                  size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 20),
              const Text(
                'Tính năng dành cho Chủ KCN và Môi giới',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Chỉ tài khoản Chủ KCN / Môi giới mới có thể đăng và quản lý bất động sản.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/home/profile'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Liên hệ nâng cấp tài khoản'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
