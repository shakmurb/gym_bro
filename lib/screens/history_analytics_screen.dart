import 'package:material_ui/material_ui.dart';

import '../gym_bro_theme.dart';
import '../models/workout_session.dart';
import '../widgets/gym_bro_components.dart';

class HistoryAnalyticsScreen extends StatefulWidget {
  const HistoryAnalyticsScreen({super.key, required this.sessions});

  final List<WorkoutSession> sessions;

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
                trailing: Text(
                  '${widget.sessions.length} LOGGED',
                  style: TextStyle(
                    color: GymBroColors.mutedGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (widget.sessions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No completed workouts yet.')),
                )
              else
                ListView.separated(
                  key: const ValueKey('workoutSessionsList'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.sessions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _SessionCard(session: widget.sessions[index]),
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
  const _SessionCard({required this.session});

  final WorkoutSession session;

  String _formatDate(DateTime? date) {
    if (date == null) return 'DATE NOT RECORDED';
    final localDate = date.toLocal();
    final year = localDate.year.toString().padLeft(4, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final day = localDate.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    if (hours > 0 && minutes > 0) return '$hours hr $minutes min';
    if (hours > 0) return '$hours hr';
    if (minutes == 0) return '$remainingSeconds sec';
    if (remainingSeconds == 0) return '$minutes min';
    return '$minutes min $remainingSeconds sec';
  }

  String _formatVolume(double volume) {
    final value = volume == volume.roundToDouble()
        ? volume.toStringAsFixed(0)
        : volume.toStringAsFixed(1);
    return '$value kg';
  }

  @override
  Widget build(BuildContext context) {
    final totalSets = session.sets.fold<int>(
      0,
      (count, exercise) => count + exercise.sets.length,
    );
    final totalVolume = session.sets.fold<double>(
      0,
      (volume, exercise) =>
          volume +
          exercise.sets.fold<double>(
            0,
            (exerciseVolume, set) =>
                exerciseVolume + set.weight * set.repetitions,
          ),
    );

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
                      _formatDate(session.date),
                      style: const TextStyle(
                        color: GymBroColors.mutedGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      session.name,
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
                            value: _formatVolume(totalVolume),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SessionStat(
                            icon: Icons.layers_outlined,
                            label: 'WORK SETS',
                            value: '$totalSets',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GymBroPill(
                      label: '${_formatDuration(session.totalTime)} TOTAL TIME',
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
