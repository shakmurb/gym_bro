import 'package:material_ui/material_ui.dart';

import '../gym_bro_theme.dart';
import '../widgets/gym_bro_components.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  static const _categories = [
    'ALL',
    'CHEST',
    'BACK',
    'SHOULDERS',
    'LEGS',
    'ARMS',
    'CORE',
  ];

  static const _exercises = [
    _Exercise(
      name: 'Barbell Bench Press (Flat)',
      category: 'CHEST',
      muscle: 'Pectoralis Major',
      equipment: 'BARBELL',
      difficulty: 'INTERMEDIATE',
      record: '105 KG × 3',
      last: '3 days ago · 3 sets',
      detail: 'EST. 1RM: 114.3 KG  ·  +2.5 KG OVERLOAD READY',
    ),
    _Exercise(
      name: 'Incline Dumbbell Press',
      category: 'CHEST',
      muscle: 'Upper Chest (Clavicular)',
      equipment: 'DUMBBELLS',
      difficulty: 'INTERMEDIATE',
      record: '36 KG × 8',
      last: 'Yesterday · 4 sets',
      detail: 'EST. 1RM: 44.8 KG  ·  VOLUME: 1,152 KG',
    ),
    _Exercise(
      name: 'Cable Chest Fly (High-to-Low)',
      category: 'CHEST',
      muscle: 'Lower Chest (Sternal)',
      equipment: 'CABLE MACHINE',
      difficulty: 'BEGINNER',
      record: '18 KG × 12',
      last: '5 days ago · 3 sets',
      detail: 'HYPERTROPHY TARGET  ·  PEAK CONTRACTION FOCUS',
    ),
    _Exercise(
      name: 'Weighted Dips',
      category: 'CHEST',
      muscle: 'Chest / Triceps',
      equipment: 'BODYWEIGHT + BELT',
      difficulty: 'ADVANCED',
      record: '+30 KG × 6',
      last: '1 week ago · 3 sets',
      detail: 'BW + LOAD RATIO: 1.36×  ·  PROGRESSION: LEVEL 4',
    ),
    _Exercise(
      name: 'Barbell Row',
      category: 'BACK',
      muscle: 'Lats / Upper Back',
      equipment: 'BARBELL',
      difficulty: 'INTERMEDIATE',
      record: '82.5 KG × 8',
      last: '2 days ago · 4 sets',
      detail: 'EST. 1RM: 104.5 KG',
    ),
    _Exercise(
      name: 'Dumbbell Shoulder Press',
      category: 'SHOULDERS',
      muscle: 'Deltoids',
      equipment: 'DUMBBELLS',
      difficulty: 'INTERMEDIATE',
      record: '26 KG × 10',
      last: '6 days ago · 3 sets',
      detail: 'VOLUME: 1,560 KG',
    ),
    _Exercise(
      name: 'High-Bar Back Squat',
      category: 'LEGS',
      muscle: 'Quadriceps / Glutes',
      equipment: 'BARBELL',
      difficulty: 'ADVANCED',
      record: '140 KG × 5',
      last: '1 week ago · 4 sets',
      detail: 'EST. 1RM: 163.3 KG',
    ),
    _Exercise(
      name: 'Incline Bicep Curl',
      category: 'ARMS',
      muscle: 'Biceps',
      equipment: 'DUMBBELLS',
      difficulty: 'BEGINNER',
      record: '16 KG × 10',
      last: '3 days ago · 3 sets',
      detail: 'HYPERTROPHY TARGET',
    ),
    _Exercise(
      name: 'Cable Crunch',
      category: 'CORE',
      muscle: 'Abdominals',
      equipment: 'CABLE MACHINE',
      difficulty: 'BEGINNER',
      record: '45 KG × 12',
      last: '5 days ago · 3 sets',
      detail: 'VOLUME: 1,620 KG',
    ),
  ];

  String _query = '';
  String _category = 'ALL';
  String _equipment = 'ALL';
  String _difficulty = 'ALL';

  List<_Exercise> get _filteredExercises {
    final normalizedQuery = _query.trim().toLowerCase();
    return _exercises.where((exercise) {
      final matchesCategory =
          _category == 'ALL' || exercise.category == _category;
      final matchesEquipment =
          _equipment == 'ALL' || exercise.equipment == _equipment;
      final matchesDifficulty =
          _difficulty == 'ALL' || exercise.difficulty == _difficulty;
      final matchesQuery =
          normalizedQuery.isEmpty ||
          exercise.name.toLowerCase().contains(normalizedQuery) ||
          exercise.muscle.toLowerCase().contains(normalizedQuery);
      return matchesCategory &&
          matchesEquipment &&
          matchesDifficulty &&
          matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _filteredExercises;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GymBroHeader(section: 'Exercise Library'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const ValueKey('exerciseSearch'),
                    onChanged: (value) => setState(() => _query = value),
                    decoration: const InputDecoration(
                      hintText: 'Search 350+ exercises',
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Add custom exercise',
                  onPressed: () => _showCustomExerciseMessage(context),
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: GymBroColors.green,
                    foregroundColor: GymBroColors.darkText,
                    minimumSize: const Size(54, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final selected = category == _category;
                  return ChoiceChip(
                    label: Text(category),
                    selected: selected,
                    onSelected: (_) => setState(() => _category = category),
                    selectedColor: GymBroColors.green,
                    backgroundColor: GymBroColors.elevatedSurface,
                    side: BorderSide(
                      color: selected
                          ? GymBroColors.green
                          : GymBroColors.border,
                    ),
                    labelStyle: TextStyle(
                      color: selected
                          ? GymBroColors.darkText
                          : GymBroColors.text,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _FilterDropdown(
                    label: 'EQUIPMENT',
                    value: _equipment,
                    options: const [
                      'ALL',
                      'BARBELL',
                      'DUMBBELLS',
                      'CABLE MACHINE',
                      'BODYWEIGHT + BELT',
                    ],
                    onChanged: (value) => setState(() => _equipment = value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterDropdown(
                    label: 'DIFFICULTY',
                    value: _difficulty,
                    options: const ['ALL', 'BEGINNER', 'INTERMEDIATE', 'ADVANCED'],
                    onChanged: (value) => setState(() => _difficulty = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GymBroSectionTitle(
              title: 'Exercises',
              trailing: Text(
                '${exercises.length} OF ${_exercises.length}',
                style: const TextStyle(
                  color: GymBroColors.mutedGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (exercises.isEmpty)
              const GymBroCard(
                child: Text('No exercises match these filters.'),
              )
            else
              for (final exercise in exercises) ...[
                _ExerciseCard(exercise: exercise),
                const SizedBox(height: 10),
              ],
            GymBroCard(
              child: Row(
                children: [
                  const Icon(Icons.playlist_add, color: GymBroColors.green),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Missing an exercise?',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Log your own custom variation with smart plate math.',
                          style: TextStyle(color: GymBroColors.mutedGreen),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _showCustomExerciseMessage(context),
                    child: const Text('ADD NEW'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomExerciseMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Custom exercise editor coming soon.')),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: GymBroColors.elevatedSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more),
          selectedItemBuilder: (context) => options
              .map(
                (option) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$label: $option',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              )
              .toList(),
          items: options
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(option, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (option) {
            if (option != null) onChanged(option);
          },
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise});

  final _Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return GymBroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: GymBroColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: GymBroColors.green.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${exercise.muscle} · ${exercise.equipment}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: GymBroColors.mutedGreen,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: GymBroColors.text),
            ],
          ),
          const SizedBox(height: 12),
          GymBroPill(
            label: 'PR: ${exercise.record}',
            icon: Icons.emoji_events,
            color: Colors.white,
            background: GymBroColors.red,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.history, size: 15, color: GymBroColors.mutedGreen),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Last: ${exercise.last}',
                  style: const TextStyle(
                    color: GymBroColors.mutedGreen,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            exercise.detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: GymBroColors.green,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _Exercise {
  const _Exercise({
    required this.name,
    required this.category,
    required this.muscle,
    required this.equipment,
    required this.difficulty,
    required this.record,
    required this.last,
    required this.detail,
  });

  final String name;
  final String category;
  final String muscle;
  final String equipment;
  final String difficulty;
  final String record;
  final String last;
  final String detail;
}
