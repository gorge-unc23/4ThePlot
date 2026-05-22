import 'package:flutter/material.dart';
import 'package:fourtheplot/models/comment.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onDelete;
  final bool isDeleting;

  const CommentCard({
    super.key,
    required this.comment,
    this.onDelete,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    final authorName = comment.author?.displayName ?? 'Guest';
    final initial = authorName.isNotEmpty ? authorName[0].toUpperCase() : '?';
    final timestamp = DateFormat('MMM d, h:mm a').format(comment.createdAt);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF151B33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF6EA8FF).withValues(alpha: 0.25),
            child: Text(
              initial,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        authorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      timestamp,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: isDeleting ? null : onDelete,
                        tooltip: 'Delete comment',
                        icon: isDeleting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.text,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    height: 1.4,
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
