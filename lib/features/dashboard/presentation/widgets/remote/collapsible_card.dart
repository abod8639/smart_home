import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';

class CollapsibleCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const CollapsibleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  State<CollapsibleCard> createState() => _CollapsibleCardState();
}

class _CollapsibleCardState extends State<CollapsibleCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Icon(widget.icon, color: AppTheme.primaryBlue, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha:0.4),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white54,
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 14.0),
              child: widget.child,
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
