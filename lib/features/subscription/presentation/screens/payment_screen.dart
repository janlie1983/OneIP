import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/pending_payment_model.dart';
import '../providers/payment_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final PendingPaymentModel payment;

  const PaymentScreen({super.key, required this.payment});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  String _status = 'pending';
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.payment.expiresAt.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining = widget.payment.expiresAt.difference(DateTime.now());
        if (_remaining.isNegative || _remaining == Duration.zero) {
          _remaining = Duration.zero;
          _timer?.cancel();
          if (_status == 'pending') _status = 'expired';
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onPaymentSuccess() {
    if (_navigated) return;
    _navigated = true;
    _timer?.cancel();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/home/site-selection');
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.navy,
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return '00:00';
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatVnd(int amount) {
    final str = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return '${buf.toString()}đ';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<String>>(
      paymentStatusProvider(widget.payment.id),
      (prev, next) {
        next.whenData((status) {
          if (!mounted) return;
          setState(() => _status = status);
          if (status == 'success') _onPaymentSuccess();
        });
      },
    );

    final qr = widget.payment.vietQRConfig;
    final isSubscription = widget.payment.paymentType == 'subscription';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(isSubscription ? 'Đăng ký Pro' : 'Xem nội dung'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _status == 'success'
          ? _buildSuccess()
          : _status == 'expired'
              ? _buildExpired()
              : _buildPending(qr),
    );
  }

  Widget _buildPending(dynamic qr) {
    final qrConfig = widget.payment.vietQRConfig;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _OrderSummaryCard(
            label: widget.payment.paymentType == 'subscription'
                ? 'Gói Pro hàng tháng'
                : 'Xem nội dung (24h)',
            amount: _formatVnd(widget.payment.amountVnd),
            remaining: _remaining,
            formatDuration: _formatDuration,
          ),
          const SizedBox(height: 20),
          _QRCard(qrUrl: qrConfig.qrUrl),
          const SizedBox(height: 16),
          _BankInfoSection(
            bankName: AppConfig.bankName,
            accountNumber: AppConfig.bankAccountNumber,
            accountName: AppConfig.bankAccountName,
          ),
          const SizedBox(height: 16),
          _TransferInfoSection(
            amount: _formatVnd(widget.payment.amountVnd),
            transferCode: widget.payment.transferCode,
            onCopy: _copyToClipboard,
          ),
          const SizedBox(height: 20),
          _StatusSection(status: _status),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: Colors.green, size: 48),
          ),
          const SizedBox(height: 20),
          const Text(
            'Thanh toán thành công!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Đang chuyển về trang chính...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildExpired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_off_rounded,
              color: AppColors.error, size: 56),
          const SizedBox(height: 16),
          const Text(
            'QR đã hết hạn',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vui lòng tạo mã QR mới để tiếp tục',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tạo QR mới'),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final Duration remaining;
  final String Function(Duration) formatDuration;

  const _OrderSummaryCard({
    required this.label,
    required this.amount,
    required this.remaining,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    final isExpiring = remaining.inMinutes < 5 && !remaining.isNegative;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textSecondary)),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined,
                  size: 16,
                  color: isExpiring ? AppColors.error : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'QR hết hạn sau: ${formatDuration(remaining)}',
                style: TextStyle(
                  fontSize: 13,
                  color: isExpiring ? AppColors.error : AppColors.textSecondary,
                  fontWeight:
                      isExpiring ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QRCard extends StatelessWidget {
  final String qrUrl;

  const _QRCard({required this.qrUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          qrUrl,
          width: 240,
          height: 240,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const SizedBox(
              width: 240,
              height: 240,
              child: Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stack) => const SizedBox(
            width: 240,
            height: 240,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_2, size: 48, color: AppColors.textSecondary),
                  SizedBox(height: 8),
                  Text('Không tải được QR',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BankInfoSection extends StatelessWidget {
  final String bankName;
  final String accountNumber;
  final String accountName;

  const _BankInfoSection({
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Ngân hàng', value: bankName),
          const SizedBox(height: 6),
          _InfoRow(label: 'Số tài khoản', value: accountNumber),
          const SizedBox(height: 6),
          _InfoRow(label: 'Chủ tài khoản', value: accountName),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.navy)),
      ],
    );
  }
}

class _TransferInfoSection extends StatelessWidget {
  final String amount;
  final String transferCode;
  final void Function(String text, String label) onCopy;

  const _TransferInfoSection({
    required this.amount,
    required this.transferCode,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin chuyển khoản',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.navy),
          ),
          const SizedBox(height: 12),
          _CopyRow(
            label: 'Số tiền',
            value: amount,
            onCopy: () => onCopy(amount.replaceAll(RegExp(r'[,đ]'), ''), 'số tiền'),
          ),
          const SizedBox(height: 8),
          _CopyRow(
            label: 'Nội dung CK',
            value: transferCode,
            onCopy: () => onCopy(transferCode, 'nội dung chuyển khoản'),
            highlight: true,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠️ ', style: TextStyle(fontSize: 13)),
                Expanded(
                  child: Text(
                    'Nhập đúng nội dung chuyển khoản để hệ thống tự động xác nhận',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.navy),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;
  final bool highlight;

  const _CopyRow({
    required this.label,
    required this.value,
    required this.onCopy,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: highlight ? AppColors.gold : AppColors.navy,
                  letterSpacing: highlight ? 1.2 : 0,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onCopy,
          icon: const Icon(Icons.copy_rounded, size: 18),
          color: AppColors.textSecondary,
          tooltip: 'Sao chép',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _StatusSection extends StatelessWidget {
  final String status;

  const _StatusSection({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (status == 'pending') ...[
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Đang chờ thanh toán...',
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }
}
