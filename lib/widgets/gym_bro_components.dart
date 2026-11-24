import 'package:material_ui/material_ui.dart';

import '../gym_bro_theme.dart';

class GymBroHeader extends StatelessWidget {
  const GymBroHeader({super.key, required this.section});

  final String section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'GYM\nBRO',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: GymBroColors.green,
                  fontWeight: FontWeight.w900,
                  height: 0.95,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: GymBroColors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: GymBroColors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: GymBroColors.elevatedSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: GymBroColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: GymBroColors.green),
                    SizedBox(width: 6),
                    Text(
                      'ONLINE',
                      style: TextStyle(
                        color: GymBroColors.text,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 19,
                backgroundColor: GymBroColors.elevatedSurface,
                child: Icon(
                  Icons.person,
                  size: 22,
                  color: GymBroColors.mutedGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            section.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: GymBroColors.mutedGreen,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class GymBroCard extends StatelessWidget {
  const GymBroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.highlighted = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: highlighted
            ? GymBroColors.elevatedSurface
            : GymBroColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted ? GymBroColors.border : const Color(0xFF21262D),
        ),
      ),
      child: child,
    );
  }
}

class GymBroSectionTitle extends StatelessWidget {
  const GymBroSectionTitle({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailingWidgets = trailing == null ? <Widget>[] : [trailing!];
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: GymBroColors.green,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...trailingWidgets,
      ],
    );
  }
}

class GymBroPill extends StatelessWidget {
  const GymBroPill({
    super.key,
    required this.label,
    this.icon,
    this.color = GymBroColors.green,
    this.background,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final iconWidgets = icon == null
        ? <Widget>[]
        : <Widget>[Icon(icon, size: 14, color: color), const SizedBox(width: 5)];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...iconWidgets,
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
