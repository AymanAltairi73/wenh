import 'package:flutter/material.dart';

class EnhancedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final bool animate;

  const EnhancedCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.onTap,
    this.color,
    this.elevation,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: elevation ?? 6,
      shadowColor: Colors.black.withOpacity(0.15),
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (!animate) return card;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
          highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
          child: card,
        ),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final String type;
  final String area;
  final String description;
  final String status;
  final String? takenBy;
  final VoidCallback? onAction;
  final String actionText;
  final bool actionEnabled;

  const RequestCard({
    super.key,
    required this.type,
    required this.area,
    required this.description,
    required this.status,
    this.takenBy,
    this.onAction,
    this.actionText = 'استلام',
    this.actionEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedCard(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.home_repair_service,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$type - $area',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'new' 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status == 'new' ? 'جديد' : 'تم الاستلام',
                  style: TextStyle(
                    color: status == 'new' ? Colors.green : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (takenBy != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'مستلم بواسطة: $takenBy',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ],
              if (onAction != null) ...[
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: actionEnabled ? onAction : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(actionText),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
