import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/services/storage/user_service_session.dart';
import 'package:project_ease/core/utils/snackbar_utils.dart';
import 'package:project_ease/features/rating/domain/entitties/rating_entity.dart';
import 'package:project_ease/features/rating/presentation/state/rating_state.dart';
import 'package:project_ease/features/rating/presentation/view_model/rating_view_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class RatingSection extends ConsumerStatefulWidget {
  final String productId;
  final bool isTablet;

  const RatingSection({
    super.key,
    required this.productId,
    required this.isTablet,
  });

  @override
  ConsumerState<RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends ConsumerState<RatingSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = ref.read(userSessionServiceProvider).getUserId();
      ref
          .read(ratingViewModelProvider.notifier)
          .loadRatings(widget.productId, currentUserId: userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ratingViewModelProvider);
    final isTablet = widget.isTablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        const SizedBox(height: 20),

        // Header
        Row(
          children: [
            Text(
              'Ratings & Reviews',
              style: TextStyle(
                fontSize: isTablet ? 15 : 13,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            if (state.totalRatings > 0)
              Text(
                '${state.totalRatings} review${state.totalRatings == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Average score bar
        if (state.totalRatings > 0) ...[
          _AverageBar(
            average: state.averageRating,
            total: state.totalRatings,
            ratings: state.ratings,
            isTablet: isTablet,
          ),
          const SizedBox(height: 16),
        ],

        // Write / edit review button
        if (state.status != RatingStatus.loading)
          _WriteReviewButton(
            productId: widget.productId,
            state: state,
            isTablet: isTablet,
          ),

        const SizedBox(height: 16),

        // Reviews list
        if (state.status == RatingStatus.loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (state.ratings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No reviews yet. Be the first!',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              ),
            ),
          )
        else
          ...state.ratings.map(
            (r) => _ReviewTile(
              rating: r,
              isOwn: r.userId == state.currentUserId,
              isTablet: isTablet,
              onEdit: () => _showRatingSheet(context, r),
              onDelete: () => _confirmDelete(context, r.ratingId),
            ),
          ),

        const SizedBox(height: 8),
      ],
    );
  }

  void _showRatingSheet(BuildContext context, [RatingEntity? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RatingSheet(
        productId: widget.productId,
        existing: existing,
        isTablet: widget.isTablet,
      ),
    );
  }

  void _confirmDelete(BuildContext context, String ratingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Delete review?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref
                  .read(ratingViewModelProvider.notifier)
                  .deleteRating(ratingId);
              if (mounted) {
                if (ok) {
                  SnackbarUtils.showSuccess(context, 'Review deleted');
                } else {
                  SnackbarUtils.showError(
                    context,
                    ref.read(ratingViewModelProvider).errorMessage ??
                        'Failed to delete',
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Average score bar

class _AverageBar extends StatelessWidget {
  final double average;
  final int total;
  final List<RatingEntity> ratings;
  final bool isTablet;

  const _AverageBar({
    required this.average,
    required this.total,
    required this.ratings,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    // Count per star
    final counts = List.generate(
      5,
      (i) => ratings.where((r) => r.rating == 5 - i).length,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Big number
        Column(
          children: [
            Text(
              average.toStringAsFixed(1),
              style: TextStyle(
                fontSize: isTablet ? 48 : 40,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            _StarRow(rating: average.round(), size: 16),
            const SizedBox(height: 2),
            Text(
              '$total reviews',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(width: 20),
        // Bar breakdown
        Expanded(
          child: Column(
            children: List.generate(5, (i) {
              final star = 5 - i;
              final count = counts[i];
              final frac = total == 0 ? 0.0 : count / total;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text(
                      '$star',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.star_rounded,
                      size: 11,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: frac,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 20,
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// Write / Edit review button

class _WriteReviewButton extends ConsumerWidget {
  final String productId;
  final RatingState state;
  final bool isTablet;

  const _WriteReviewButton({
    required this.productId,
    required this.state,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myRating = state.myRating;

    return OutlinedButton.icon(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _RatingSheet(
            productId: productId,
            existing: myRating,
            isTablet: isTablet,
          ),
        );
      },
      icon: Icon(
        myRating != null ? Icons.edit_rounded : Icons.rate_review_outlined,
        size: 16,
      ),
      label: Text(myRating != null ? 'Edit your review' : 'Write a review'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}

// Individual review tile

class _ReviewTile extends StatelessWidget {
  final RatingEntity rating;
  final bool isOwn;
  final bool isTablet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReviewTile({
    required this.rating,
    required this.isOwn,
    required this.isTablet,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(
                  (rating.userName?.isNotEmpty == true)
                      ? rating.userName![0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isOwn ? 'You' : (rating.userName ?? 'Anonymous'),
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        if (isOwn) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Your review',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    _StarRow(rating: rating.rating, size: 13),
                  ],
                ),
              ),
              // Timestamp
              Text(
                timeago.format(rating.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
              // Edit/delete menu for own review
              if (isOwn)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rating.review,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
        ],
      ),
    );
  }
}

// Star row helper

class _StarRow extends StatelessWidget {
  final int rating;
  final double size;

  const _StarRow({required this.rating, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: i < rating ? AppColors.primary : Colors.grey.shade300,
        ),
      ),
    );
  }
}

// Rating bottom sheet

class _RatingSheet extends ConsumerStatefulWidget {
  final String productId;
  final RatingEntity? existing; // null = new, non-null = edit
  final bool isTablet;

  const _RatingSheet({
    required this.productId,
    this.existing,
    required this.isTablet,
  });

  @override
  ConsumerState<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends ConsumerState<_RatingSheet> {
  late int _selectedRating;
  late final TextEditingController _reviewCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.existing?.rating ?? 0;
    _reviewCtrl = TextEditingController(text: widget.existing?.review ?? '');
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  bool get _isEdit => widget.existing != null;

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(
      ratingViewModelProvider.select(
        (s) => s.status == RatingStatus.submitting,
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    _isEdit ? 'Edit your review' : 'Write a review',
                    style: TextStyle(
                      fontSize: widget.isTablet ? 18 : 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Star selector
                  Center(
                    child: _StarSelector(
                      selected: _selectedRating,
                      onChanged: (v) => setState(() => _selectedRating = v),
                    ),
                  ),

                  if (_selectedRating == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Center(
                        child: Text(
                          'Tap a star to rate',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Review text field
                  TextFormField(
                    controller: _reviewCtrl,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: 'Share your experience with this product...',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please write a review';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submit,
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black,
                              ),
                            )
                          : Text(_isEdit ? 'Update Review' : 'Submit Review'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedRating == 0) {
      SnackbarUtils.showError(context, 'Please select a star rating');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(ratingViewModelProvider.notifier);

    bool ok;
    if (_isEdit) {
      ok = await notifier.updateRating(
        ratingId: widget.existing!.ratingId,
        rating: _selectedRating,
        review: _reviewCtrl.text.trim(),
      );
    } else {
      ok = await notifier.submitRating(
        productId: widget.productId,
        rating: _selectedRating,
        review: _reviewCtrl.text.trim(),
      );
    }

    if (mounted) {
      if (ok) {
        Navigator.pop(context);
        SnackbarUtils.showSuccess(
          context,
          _isEdit ? 'Review updated!' : 'Review submitted!',
        );
      } else {
        final err = ref.read(ratingViewModelProvider).errorMessage;
        SnackbarUtils.showError(context, err ?? 'Something went wrong');
      }
    }
  }
}

// Interactive star selector

class _StarSelector extends StatelessWidget {
  final int selected;
  final void Function(int) onChanged;

  const _StarSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final star = i + 1;
        return GestureDetector(
          onTap: () => onChanged(star),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              star <= selected
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              size: 40,
              color: star <= selected
                  ? AppColors.primary
                  : Colors.grey.shade300,
            ),
          ),
        );
      }),
    );
  }
}
