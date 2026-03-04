import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/features/store/domain/entities/store_entity.dart';
import 'package:project_ease/features/store/presentation/pages/store_map_screen.dart';
import 'package:project_ease/features/store/presentation/state/store_state.dart';
import 'package:project_ease/features/store/presentation/view_model/store_view_model.dart';

class StoreDropdown extends ConsumerWidget {
  final bool isTablet;
  const StoreDropdown({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeState = ref.watch(storeViewModelProvider);

    if (storeState.status == StoreStatus.loading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (storeState.stores.isEmpty) {
      return Text(
        'No stores',
        style: TextStyle(fontSize: isTablet ? 14 : 12, color: Colors.grey),
      );
    }

    return GestureDetector(
      onTap: () => _showStoreBottomSheet(context, ref, storeState),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.store_outlined,
              size: isTablet ? 16 : 14,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 160 : 110),
              child: Text(
                storeState.selectedStore?.name ?? 'Select Store',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: isTablet ? 18 : 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showStoreBottomSheet(
    BuildContext context,
    WidgetRef ref,
    StoreState storeState,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _StorePickerSheet(
        stores: storeState.stores,
        selectedStore: storeState.selectedStore,
        isTablet: MediaQuery.of(context).size.width >= 600,
        onSelect: (store) {
          ref.read(storeViewModelProvider.notifier).selectStore(store);
          Navigator.pop(ctx);
        },
        onViewMap: () {
          Navigator.pop(ctx);
          _openMap(context, ref);
        },
      ),
    );
  }

  Future<void> _openMap(BuildContext context, WidgetRef ref) async {
    final picked = await Navigator.push<StoreEntity>(
      context,
      MaterialPageRoute(builder: (_) => const StoreMapScreen()),
    );
    if (picked != null) {
      ref.read(storeViewModelProvider.notifier).selectStore(picked);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _StorePickerSheet extends StatelessWidget {
  final List<StoreEntity> stores;
  final StoreEntity? selectedStore;
  final bool isTablet;
  final void Function(StoreEntity) onSelect;
  final VoidCallback onViewMap;

  const _StorePickerSheet({
    required this.stores,
    required this.selectedStore,
    required this.isTablet,
    required this.onSelect,
    required this.onViewMap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Select a Store',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              // View on map button
              GestureDetector(
                onTap: onViewMap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'View on map',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...stores.map((store) {
            final isSelected = selectedStore?.storeId == store.storeId;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.store_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                store.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : Colors.black87,
                ),
              ),
              subtitle: store.description != null
                  ? Text(
                      store.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () => onSelect(store),
            );
          }),
        ],
      ),
    );
  }
}
