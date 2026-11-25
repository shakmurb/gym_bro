import 'package:material_ui/material_ui.dart';

import '../gym_bro_theme.dart';
import '../widgets/gym_bro_components.dart';

class HistoryAnalyticsScreen extends StatefulWidget {
  const HistoryAnalyticsScreen({super.key});

  @override
  State<HistoryAnalyticsScreen> createState() => _HistoryAnalyticsScreenState();
}

class _HistoryAnalyticsScreenState extends State<HistoryAnalyticsScreen> {
  bool _showAnalytics = false;
  String _selectedRange = '3M';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GymBroHeader(section: 'History Analytics'),
            Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'WORKOUT LOGS',
                    selected: !_showAnalytics,
                    onPressed: () => setState(() => _showAnalytics = false),
                  ),
                ),
                Expanded(
                  child: _TabButton(
                    label: 'PROGRESS & ANALYTICS',
                    selected: _showAnalytics,
                    onPressed: () => setState(() => _showAnalytics = true),
                  ),
                ),
                IconButton(
                  tooltip: 'Export PDF',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PDF export is not connected yet.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_outlined),
                ),
              ],
            ),
            const SizedBox(height: 18),
            GymBroCard(
              highlighted: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: GymBroColors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'OCTOBER MACRO PERFORMANCE',
                          style: TextStyle(
                            color: GymBroColors.mutedGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      GymBroPill(
                        label: _showAnalytics ? 'RISING' : 'PEAK PACE',
                        color: GymBroColors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: const [
                      Expanded(
                        child: _SummaryMetric(
                          label: 'TOTAL VOLUME',
                          value: '142,500',
                          unit: 'KG LIFTED',
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _SummaryMetric(
                          label: 'WORKOUTS',
                          value: '18 / 20',
                          unit: 'THIS MONTH',
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _SummaryMetric(
                          label: 'NEW RECORDS',
                          value: '7',
                          unit: 'OVERLOADS',
                          accent: GymBroColors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (!_showAnalytics) ...[
              GymBroSectionTitle(
                title: 'Past Sessions',
                trailing: const Text(
                  '3 LOGGED THIS WEEK',
                  style: TextStyle(
                    color: GymBroColors.mutedGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _SessionCard(
                date: 'YESTERDAY · OCT 24 · 58 MINS',
                title: 'Push Day - Chest, Shoulders & Triceps',
                volume: '12,450 kg',
                sets: '18 Total Sets',
                highlight: '2 NEW PRs · BENCH 102.5 KG · LAT 16 KG',
                duration: '42m Lifting / 16m Rest',
              ),
              const SizedBox(height: 10),
              const _SessionCard(
                date: 'TUESDAY, OCT 22 · 64 MINS',
                title: 'Pull Day - Heavy Deadlifts & Back',
                volume: '14,800 kg',
                sets: '16 Sets',
                highlight: '+5 KG PROGRESSIVE OVERLOAD',
                duration: '94% TARGET INTENSITY',
              ),
              const SizedBox(height: 10),
              const _SessionCard(
                date: 'SUNDAY, OCT 20 · 52 MINS',
                title: 'Leg Day - Squat Focus & Calves',
                volume: '11,200 kg',
                sets: '14 Sets Completed',
                highlight: 'HIGH BAR SQUATS · 140 KG × 5',
                duration: 'RPE 8.5 AVG',
              ),
            ],
            if (_showAnalytics) ...[
              const SizedBox(height: 24),
              GymBroSectionTitle(
                title: 'Strength Analytics',
                trailing: const Text(
                  'ESTIMATED 1RM',
                  style: TextStyle(
                    color: GymBroColors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GymBroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EXERCISE TRAJECTORY',
                                style: TextStyle(
                                  color: GymBroColors.mutedGreen,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Barbell Bench Press',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '114.3',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: GymBroColors.green,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const Text(
                              '+16.6% OVER 8 WKS',
                              style: TextStyle(
                                color: GymBroColors.green,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 4,
                      children: ['1M', '3M', '6M', '1Y', 'ALL']
                          .map(
                            (label) => ChoiceChip(
                              label: Text(label),
                              selected: label == _selectedRange,
                              onSelected: (_) =>
                                  setState(() => _selectedRange = label),
                              showCheckmark: false,
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: CustomPaint(painter: _TrajectoryPainter()),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Icon(
                          Icons.verified_outlined,
                          size: 18,
                          color: GymBroColors.green,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Calculated via Epley Formula',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Text(
                          'RPE 9.5 AVG',
                          style: TextStyle(
                            color: GymBroColors.mutedGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: selected
            ? GymBroColors.green
            : GymBroColors.elevatedSurface,
        foregroundColor: selected
            ? GymBroColors.darkText
            : GymBroColors.mutedGreen,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        minimumSize: const Size(0, 42),
        textStyle: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.unit,
    this.accent = GymBroColors.text,
  });

  final String label;
  final String value;
  final String unit;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: GymBroColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: GymBroColors.mutedGreen,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: accent,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.date,
    required this.title,
    required this.volume,
    required this.sets,
    required this.highlight,
    required this.duration,
  });

  final String date;
  final String title;
  final String volume;
  final String sets;
  final String highlight;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return GymBroCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: GymBroColors.green,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        color: GymBroColors.mutedGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SessionStat(
                            icon: Icons.scale_outlined,
                            label: 'TOTAL VOLUME',
                            value: volume,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SessionStat(
                            icon: Icons.layers_outlined,
                            label: 'WORK SETS',
                            value: sets,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GymBroPill(
                      label: highlight,
                      icon: Icons.bolt,
                      color: Colors.white,
                      background: GymBroColors.red,
                    ),
                    const SizedBox(height: 8),
                    GymBroPill(
                      label: duration,
                      icon: Icons.timer_outlined,
                      color: GymBroColors.mutedGreen,
                      background: GymBroColors.elevatedSurface,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('VIEW DETAILS & PDF'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: GymBroColors.text,
                          side: const BorderSide(color: GymBroColors.border),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionStat extends StatelessWidget {
  const _SessionStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: GymBroColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: GymBroColors.mutedGreen),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: GymBroColors.mutedGreen,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TrajectoryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = GymBroColors.border
      ..strokeWidth = 1;
    for (var index = 0; index < 4; index++) {
      final y = size.height * index / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final values = [0.12, 0.25, 0.34, 0.51, 0.62, 0.82, 0.96];
    final points = [
      for (var index = 0; index < values.length; index++)
        Offset(
          size.width * index / (values.length - 1),
          size.height * (1 - values[index]),
        ),
    ];
    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      line.lineTo(point.dx, point.dy);
    }

    final linePaint = Paint()
      ..color = GymBroColors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(line, linePaint);

    final pointPaint = Paint()..color = GymBroColors.green;
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
