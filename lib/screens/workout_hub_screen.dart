import 'package:material_ui/material_ui.dart';

import '../gym_bro_theme.dart';
import '../widgets/gym_bro_components.dart';

class WorkoutHubScreen extends StatelessWidget {
  const WorkoutHubScreen({super.key, required this.onStartWorkout});

  final VoidCallback onStartWorkout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GymBroHeader(section: 'Workout'),
            GymBroCard(
              highlighted: true,
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
                    const SizedBox(width: 14),
                    const Icon(Icons.bolt, color: GymBroColors.green, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                GymBroPill(
                                  label: 'OVERLOAD ALERT',
                                  color: GymBroColors.darkText,
                                  background: GymBroColors.green,
                                ),
                                Text(
                                  '+2.5 KG REC',
                                  style: TextStyle(
                                    color: GymBroColors.mutedGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Bench Press +2.5kg recommended today based on hitting 3×10 last session.',
                              style: TextStyle(
                                color: GymBroColors.text,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Expanded(
                  child: _QuickMetric(
                    icon: Icons.local_fire_department,
                    label: 'STREAK',
                    value: '4 Days',
                    accent: GymBroColors.red,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _QuickMetric(
                    icon: Icons.checklist,
                    label: 'WEEKLY GOAL',
                    value: '3/4 Done',
                    accent: GymBroColors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GymBroCard(
              highlighted: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: GymBroColors.green,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'UP NEXT · TODAY',
                            style: TextStyle(
                              color: GymBroColors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Last: 4 days ago',
                        style: TextStyle(
                          color: GymBroColors.mutedGreen,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Push Day (Hypertrophy)',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      GymBroPill(
                        label: '5 EXERCISES',
                        icon: Icons.fitness_center,
                        color: GymBroColors.text,
                        background: GymBroColors.background,
                      ),
                      GymBroPill(
                        label: '~55 MINS',
                        icon: Icons.schedule,
                        color: GymBroColors.mutedGreen,
                        background: GymBroColors.background,
                      ),
                      GymBroPill(
                        label: '8,400 KG TARGET',
                        icon: Icons.equalizer,
                        color: GymBroColors.green,
                        background: GymBroColors.background,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GymBroColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          color: GymBroColors.mutedGreen,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PRIMARY LIFT · SET 1 READY',
                                style: TextStyle(
                                  color: GymBroColors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Flat Barbell Bench Press',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const ValueKey('startWorkout'),
                      onPressed: onStartWorkout,
                      icon: const Icon(Icons.bolt),
                      label: const Text('START WORKOUT'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showComingSoon(
                        context,
                        'Freestyle sessions are coming soon.',
                      ),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Start Empty / Freestyle Session'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        foregroundColor: GymBroColors.text,
                        side: const BorderSide(color: GymBroColors.border),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GymBroSectionTitle(
              title: 'My Routines',
              trailing: TextButton.icon(
                onPressed: () => _showComingSoon(
                  context,
                  'The routine editor is coming soon.',
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('NEW SPLIT'),
              ),
            ),
            const SizedBox(height: 12),
            const _RoutineCard(
              title: 'Push / Pull / Legs (PPL)',
              label: 'ACTIVE',
              schedule: '3 Days / Week',
              goal: 'Hypertrophy & Density',
              movements: 'Incline Dumbbell Bench, Overhead Barbell Press, Weighted Dips',
            ),
            const SizedBox(height: 10),
            const _RoutineCard(
              title: 'Upper / Lower Beast',
              schedule: '4 Days / Week',
              goal: 'Strength & Progressive Tension',
              movements: 'Barbell Bench Press, Barbell Rows, Back Squats, Romanian Deadlifts',
            ),
            const SizedBox(height: 10),
            const _RoutineCard(
              title: 'Arm Farm & Core',
              schedule: '2 Days / Week',
              goal: 'Specialization & Pump',
              movements:
                  'Incline Bicep Curls, Rope Tricep Pushdowns, Cable Crunches',
            ),
            const SizedBox(height: 20),
            GymBroCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 9, color: GymBroColors.green),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SCHEDULED TODAY',
                          style: TextStyle(
                            color: GymBroColors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Push A · 6:00 PM Warmup',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showComingSoon(
                      context,
                      'Scheduled workout logging is coming soon.',
                    ),
                    child: const Text('LOG NOW'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showComingSoon(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _QuickMetric extends StatelessWidget {
  const _QuickMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GymBroCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GymBroColors.mutedGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.title,
    required this.schedule,
    required this.goal,
    required this.movements,
    this.label,
  });

  final String title;
  final String schedule;
  final String goal;
  final String movements;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return GymBroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const Icon(Icons.edit_outlined, color: GymBroColors.mutedGreen),
            ],
          ),
          if (label != null) ...[
            const SizedBox(height: 6),
            GymBroPill(label: label!, color: GymBroColors.green),
          ],
          const SizedBox(height: 8),
          Text(
            '$schedule  ·  $goal',
            style: const TextStyle(
              color: GymBroColors.mutedGreen,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: GymBroColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'KEY MOVEMENTS\n$movements',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(height: 1.5, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
