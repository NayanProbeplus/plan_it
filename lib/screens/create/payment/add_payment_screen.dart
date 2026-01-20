// lib/screens/create/payment/payment_reminders_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:planit/services/isar_services.dart';
import 'package:planit/theme/colors.dart';
import 'package:planit/utils/utilities.dart';
import 'package:planit/widgets/glass_edittexts_textfields.dart';
import 'package:planit/widgets/gradient_text.dart';
import 'package:planit/widgets/slide_to_confirm_button.dart';
import 'package:planit/widgets/staggered_fade_animation.dart';
import 'package:planit/models/payment_reminder.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  State<AddPaymentScreen> createState() => AddPaymentScreenState();
}

class AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedPaymentOption;
  String? _selectedPaymentType;
  DateTime? _selectedDate;

  // Animation timings (similar vibe to ProfileScreen, a bit snappier)
  final Duration topInitialDelay = const Duration(milliseconds: 0);
  final Duration delayBetween = const Duration(milliseconds: 30);
  final Duration fadeDuration = const Duration(milliseconds: 300);

  // Top "Payment type" dropdown
  final _paymentTypes = const [
    'Credit card bill',
    'Netflix',
    'Prime',
    'iCloud',
    'Electricity bill',
    'Utility bill',
    'Rent',
    'Loan EMI',
    'Other',
  ];

  // "Payment option" dropdown
  final _paymentOptions = const [
    'UPI',
    'Credit card',
    'Debit card',
    'Net banking',
    'Wallet',
    'Cash',
    'Auto-debit',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _selectedDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Persist to Isar and return true on success.
  Future<bool> _onAddPayment() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      AppToast.show('Please fix the errors in the form');
      return false;
    }

    if (_selectedPaymentType == null) {
      AppToast.show('Please select a payment type');
      return false;
    }

    if (_selectedDate == null) {
      AppToast.show('Please select a due date');
      return false;
    }

    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim();
    final parsedAmount = double.tryParse(amountText.replaceAll(',', '').trim());

    if (parsedAmount == null || parsedAmount <= 0) {
      AppToast.show('Please enter a valid amount');
      return false;
    }

    final option = _selectedPaymentOption ?? 'Not selected';
    final type = _selectedPaymentType!;
    final date = _selectedDate!;

    // Create the model using factory which sets createdAt
    final reminder = PaymentReminder.create(
      paymentType: type,
      name: name,
      amount: parsedAmount,
      paymentOption: option,
      dueDate: date,
    );

    try {
      int savedId = -1;
      await IsarService.isar.writeTxn(() async {
        savedId = await IsarService.isar.paymentReminders.put(reminder);
      });
      debugPrint('Saved reminder assigned id: $savedId');

      // schedule notification for this reminder (2 days before due)
      const notifTitle = 'Upcoming payment due';
      final notifBody =
          '${reminder.name} due on ${DateFormat.yMMMd().format(reminder.dueDate)}';

      scheduleOrShowReminderNotification(
        id: savedId,
        title: notifTitle,
        body: notifBody,
        dueDate: reminder.dueDate,
      );

      _printAllRemindersFromDb();

      DateFormat.yMMMd().format(date);

      AppToast.show(
          'Payment created. Please check Overview screen for updates');

      // clear inputs after successful save
      setState(() {
        _nameController.clear();
        _amountController.clear();
        _selectedPaymentOption = null;
        _selectedPaymentType = null;
        _selectedDate = null;
      });

      return true;
    } catch (e, st) {
      debugPrint('Isar write error: $e\n$st');
      AppToast.show('Error saving payment. Please try again.');
      return false;
    }
  }

  Future<void> _printAllRemindersFromDb() async {
    try {
      final all = await IsarService.isar.paymentReminders.where().findAll();
      debugPrint('--- DB: all reminders (${all.length}) ---');
      for (final r in all) {
        debugPrint(
            'id:${r.id} type:${r.paymentType} name:${r.name} amount:${r.amount} due:${r.dueDate.toIso8601String()} created:${r.createdAt.toIso8601String()}');
      }
      debugPrint('----------------------------------------');
    } catch (e, st) {
      debugPrint('Error reading reminders: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final dateText = _selectedDate == null
        ? 'Choose date'
        : DateFormat.yMMMd().format(_selectedDate!);

    final topChildren = <Widget>[
      const SizedBox(height: 4),

      GradientText(
        'Add a payment',
        gradient: AppColors.vibrantGradientBg,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Quicksand',
        ),
      ),

      const SizedBox(height: 4),
      Text(
        'We’ll remind you before it’s due.',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          fontFamily: 'MomoSignature',
          color: cs.secondary, // ✅ theme aware
        ),
      ),

      const SizedBox(height: 20),

      // -------- Payment type ----------
      Text(
        'Payment type',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Quicksand',
          color: cs.onSurface.withOpacity(0.75), // ✅
        ),
      ),
      const SizedBox(height: 6),

      GlassInputWrapper(
        child: Theme(
          data: theme.copyWith(canvasColor: cs.surface), // ✅
          child: DropdownButtonFormField<String>(
            value: _selectedPaymentType,
            dropdownColor: cs.surface, // ✅
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: cs.onSurface.withOpacity(0.6)),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 14,
              color: cs.onSurface, // ✅
            ),
            hint: Text(
              'Select a type',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 13,
                color: cs.onSurface.withOpacity(0.6),
              ),
            ),
            items: _paymentTypes
                .map((opt) => DropdownMenuItem(
                      value: opt,
                      child: Text(opt, style: TextStyle(color: cs.onSurface)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedPaymentType = v),
          ),
        ),
      ),

      const SizedBox(height: 18),

      // -------- Payment name ----------
      Text(
        'Payment name',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Quicksand',
          color: cs.onSurface.withOpacity(0.75),
        ),
      ),
      const SizedBox(height: 6),

      GlassInputWrapper(
        child: TextFormField(
          controller: _nameController,
          cursorColor: cs.primary,
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: cs.onSurface, // ✅
          ),
          decoration: InputDecoration(
            hintText: 'e.g. HDFC Card',
            hintStyle: TextStyle(
              color: cs.onSurface.withOpacity(0.5),
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Enter a payment name' : null,
        ),
      ),

      const SizedBox(height: 16),

      // -------- Amount + Date ----------
      Row(
        children: [
          Expanded(
            child: GlassInputWrapper(
              child: TextFormField(
                controller: _amountController,
                cursorColor: cs.primary,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(color: cs.onSurface),
                  hintText: '1200',
                  hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.5)),
                  border: InputBorder.none,
                ),
                validator: (v) {
                  final parsed =
                      double.tryParse(v?.replaceAll(',', '').trim() ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter valid amount';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GlassInputWrapper(
              child: InkWell(
                onTap: _pickDate,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        dateText,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w700,
                          color: _selectedDate == null
                              ? cs.onSurface.withOpacity(0.5)
                              : cs.onSurface,
                        ),
                      ),
                    ),
                    Icon(Icons.calendar_today_rounded,
                        size: 16, color: cs.onSurface.withOpacity(0.6)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 24),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ✅
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Payment reminders',
          style: TextStyle(
            color: cs.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            fontFamily: 'Quicksand',
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Form(
                  key: _formKey,
                  child: StaggeredFade(
                    initialDelay: topInitialDelay,
                    delayBetween: delayBetween,
                    fadeDuration: fadeDuration,
                    children: topChildren,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SlideToConfirmButton(
                visible: true,
                title: 'Slide to add',
                resetOnSuccess: true,
                width: MediaQuery.of(context).size.width - 32,
                onConfirmed: _onAddPayment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
