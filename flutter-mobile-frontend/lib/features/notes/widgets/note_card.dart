import 'package:flutter/material.dart';
import '../models/note.dart';
import '../../../core/theme/app_theme.dart';

class NoteCard extends StatefulWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool _showDeleteOption = false;

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return '${_month(date.month)} ${date.day}, ${date.year}';
  }

  String _month(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_showDeleteOption) {
          setState(() => _showDeleteOption = false);
          return;
        }
        widget.onTap();
      },
      onLongPress: () => setState(() => _showDeleteOption = true),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSoft),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: .07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Stack(
            children: [

              /* ── Amber top bar ── */
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.amber, AppColors.amberGlow],
                    ),
                  ),
                ),
              ),

              /* ── Note content ── */
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.lg,
                  AppSpacing.md, AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.note.title,
                      style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        widget.note.content,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _formatDate(widget.note.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              /* ── Delete popup overlay ── */
              if (_showDeleteOption)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.ink.withValues(alpha: .92),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Delete note?',
                          style: Theme.of(context)
                            .textTheme.bodySmall
                            ?.copyWith(
                              color: AppColors.amber,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.note.title,
                          style: Theme.of(context)
                            .textTheme.headlineMedium
                            ?.copyWith(
                              color: AppColors.cream,
                              fontSize: 14,
                            ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /* Delete button */
                            GestureDetector(
                              onTap: () {
                                setState(() => _showDeleteOption = false);
                                widget.onDelete();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.redSoft,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm),
                                ),
                                child: Text(
                                  'Delete',
                                  style: Theme.of(context)
                                    .textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            /* Cancel button */
                            GestureDetector(
                              onTap: () =>
                                setState(() => _showDeleteOption = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .15),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: .3),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: Theme.of(context)
                                    .textTheme.bodySmall
                                    ?.copyWith(color: AppColors.cream),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}