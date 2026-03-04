import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/utils/snackbar_utils.dart';
import 'package:project_ease/features/support/domain/entities/ticket_entity.dart';
import 'package:project_ease/features/support/presentation/pages/ticket_chat_screen.dart';
import 'package:project_ease/features/support/presentation/state/support_state.dart';
import 'package:project_ease/features/support/presentation/view_model/support_view_model.dart';

class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  TicketCategory _category = TicketCategory.other;
  TicketPriority _priority = TicketPriority.medium;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(
      ticketListViewModelProvider.select(
        (s) => s.status == SupportStatus.submitting,
      ),
    );
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'New Ticket',
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          isTablet ? 32 : 20,
          20,
          isTablet ? 32 : 20,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Title'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  hintText: 'Brief summary of the issue',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 20),

              _label('Description'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Describe the issue in detail...',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 20),

              _label('Category'),
              const SizedBox(height: 8),
              _CategorySelector(
                selected: _category,
                onChanged: (c) => setState(() => _category = c),
              ),
              const SizedBox(height: 20),

              _label('Priority'),
              const SizedBox(height: 8),
              _PrioritySelector(
                selected: _priority,
                onChanged: (p) => setState(() => _priority = p),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Submit Ticket',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Colors.black54,
      letterSpacing: 0.3,
    ),
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ticket = await ref
        .read(ticketListViewModelProvider.notifier)
        .createTicket(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          category: _category.value,
          priority: _priority.value,
        );
    if (!mounted) return;
    if (ticket != null) {
      // Navigate directly into the new ticket's chat
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TicketChatScreen(ticket: ticket)),
      );
    } else {
      final err = ref.read(ticketListViewModelProvider).errorMessage;
      SnackbarUtils.showError(context, err ?? 'Failed to create ticket');
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category selector chips
// ─────────────────────────────────────────────────────────────────────────────

class _CategorySelector extends StatelessWidget {
  final TicketCategory selected;
  final void Function(TicketCategory) onChanged;

  const _CategorySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TicketCategory.values.map((c) {
        final isSelected = c == selected;
        return GestureDetector(
          onTap: () => onChanged(c),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.2),
              ),
            ),
            child: Text(
              c.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.black : AppColors.primary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Priority selector
// ─────────────────────────────────────────────────────────────────────────────

class _PrioritySelector extends StatelessWidget {
  final TicketPriority selected;
  final void Function(TicketPriority) onChanged;

  const _PrioritySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        TicketPriority.low,
        Colors.green.shade400,
        Icons.keyboard_double_arrow_down_rounded,
      ),
      (
        TicketPriority.medium,
        Colors.orange.shade400,
        Icons.drag_handle_rounded,
      ),
      (
        TicketPriority.high,
        Colors.red.shade400,
        Icons.keyboard_double_arrow_up_rounded,
      ),
    ];
    return Row(
      children: items.map((item) {
        final (p, color, icon) = item;
        final isSelected = p == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(p),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.15)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected ? color : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? color : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
