import 'package:material_ui/material_ui.dart';

import '../models/exercise.dart';
import '../models/exercise_set.dart';

class ActiveWorkoutExerciseCard extends StatelessWidget {
  const ActiveWorkoutExerciseCard({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    required this.exerciseCount,
    required this.completedSets,
    required this.currentSetIndex,
    required this.canCompleteSet,
    required this.onAdjustSet,
    required this.onEditWeight,
    required this.onCompleteSet,
  });

  final Exercise exercise;
  final int exerciseIndex;
  final int exerciseCount;
  final List<bool> completedSets;
  final int currentSetIndex;
  final bool Function(int exerciseIndex, int setIndex) canCompleteSet;
  final void Function(int, int, double, int) onAdjustSet;
  final Future<void> Function(int exerciseIndex, int setIndex) onEditWeight;
  final Future<void> Function(int exerciseIndex, int setIndex) onCompleteSet;

  @override
  Widget build(BuildContext context) {
    final maxReps = exercise.sets.fold<int>(
      0,
      (maximum, set) => maximum > set.repetitions ? maximum : set.repetitions,
    );
    return Container(
      key: ValueKey('exerciseCard$exerciseIndex'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ActiveWorkoutColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: ActiveWorkoutColors.surfaceHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  'EXERCISE ${exerciseIndex + 1} OF $exerciseCount',
                  style: const TextStyle(
                    color: ActiveWorkoutColors.primary,
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  exercise.mainMuscleGroup.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ActiveWorkoutColors.onSurfaceVariant,
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            exercise.name,
            style: const TextStyle(
              color: ActiveWorkoutColors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Target: ${exercise.sets.length} sets · up to $maxReps reps'
            ' · Rest: ${exercise.recommendedRestTime}s',
            style: const TextStyle(
              color: ActiveWorkoutColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          if (exercise.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              exercise.description,
              style: const TextStyle(
                color: ActiveWorkoutColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(flex: 1, child: _TableLabel('SET')),
              Expanded(flex: 2, child: _TableLabel('PREV')),
              SizedBox(width: 68, child: _TableLabel('KG')),
              SizedBox(width: 8),
              SizedBox(width: 84, child: _TableLabel('REPS')),
              SizedBox(width: 44, child: _TableLabel('LOG')),
            ],
          ),
          const SizedBox(height: 6),
          for (var setIndex = 0; setIndex < exercise.sets.length; setIndex++)
            _SetRow(
              setNumber: setIndex + 1,
              exerciseIndex: exerciseIndex,
              setIndex: setIndex,
              exerciseSet: exercise.sets[setIndex],
              isCompleted: completedSets[setIndex],
              isCurrent: currentSetIndex == setIndex,
              onAdjustSet: onAdjustSet,
              onEditWeight: onEditWeight,
              onComplete: canCompleteSet(exerciseIndex, setIndex)
                  ? () => onCompleteSet(exerciseIndex, setIndex)
                  : null,
            ),
          if (currentSetIndex >= 0 &&
              currentSetIndex < exercise.sets.length &&
              canCompleteSet(exerciseIndex, currentSetIndex))
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  key: ValueKey('completeSet$exerciseIndex-$currentSetIndex'),
                  onPressed: () =>
                      onCompleteSet(exerciseIndex, currentSetIndex),
                  style: FilledButton.styleFrom(
                    backgroundColor: ActiveWorkoutColors.primary,
                    foregroundColor: ActiveWorkoutColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    'COMPLETE SET ${currentSetIndex + 1}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.setNumber,
    required this.exerciseIndex,
    required this.setIndex,
    required this.exerciseSet,
    required this.isCompleted,
    required this.isCurrent,
    required this.onAdjustSet,
    required this.onEditWeight,
    required this.onComplete,
  });

  final int setNumber;
  final int exerciseIndex;
  final int setIndex;
  final ExerciseSet exerciseSet;
  final bool isCompleted;
  final bool isCurrent;
  final void Function(int, int, double, int) onAdjustSet;
  final Future<void> Function(int exerciseIndex, int setIndex) onEditWeight;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final background = isCurrent
        ? ActiveWorkoutColors.surfaceHigh
        : ActiveWorkoutColors.surfaceLow;
    return Container(
      height: 54,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: isCurrent
            ? const Border(
                left: BorderSide(color: ActiveWorkoutColors.primary, width: 3),
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$setNumber',
              style: TextStyle(
                color: isCompleted || isCurrent
                    ? ActiveWorkoutColors.primary
                    : ActiveWorkoutColors.onSurfaceVariant,
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: const Text(
              '—',
              style: TextStyle(
                color: ActiveWorkoutColors.onSurfaceVariant,
                fontFamily: 'monospace',
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(
            width: 68,
            child: _EditableWeight(
              value: _formatWeight(exerciseSet.weight),
              key: ValueKey('weightValue$exerciseIndex-$setIndex'),
              onTap: () => onEditWeight(exerciseIndex, setIndex),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 84,
            child: _SetValueStepper(
              key: ValueKey('repsValue$exerciseIndex-$setIndex'),
              value: '${exerciseSet.repetitions}',
              decreaseKey: ValueKey('decreaseReps$exerciseIndex-$setIndex'),
              increaseKey: ValueKey('increaseReps$exerciseIndex-$setIndex'),
              onDecrease: () => onAdjustSet(exerciseIndex, setIndex, 0, -1),
              onIncrease: () => onAdjustSet(exerciseIndex, setIndex, 0, 1),
            ),
          ),
          SizedBox(
            width: 44,
            height: 46,
            child: IconButton(
              tooltip: isCompleted ? 'Set complete' : 'Complete set $setNumber',
              onPressed: onComplete,
              style: IconButton.styleFrom(
                backgroundColor: isCompleted
                    ? ActiveWorkoutColors.primary
                    : isCurrent
                    ? ActiveWorkoutColors.surfaceHighest
                    : ActiveWorkoutColors.surfaceHigh,
                foregroundColor: isCompleted
                    ? ActiveWorkoutColors.onPrimary
                    : ActiveWorkoutColors.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(
                isCompleted
                    ? Icons.check
                    : isCurrent
                    ? Icons.play_arrow
                    : Icons.more_horiz,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatWeight(double weight) =>
    weight == weight.roundToDouble() ? weight.toInt().toString() : '$weight';

class _EditableWeight extends StatelessWidget {
  const _EditableWeight({super.key, required this.value, required this.onTap});

  final String value;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: ActiveWorkoutColors.surface,
    borderRadius: BorderRadius.circular(4),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 38,
        child: Center(
          child: Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: const TextStyle(
              color: ActiveWorkoutColors.primary,
              fontFamily: 'monospace',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ),
  );
}

class ActiveWorkoutWeightEditorDialog extends StatefulWidget {
  const ActiveWorkoutWeightEditorDialog({
    super.key,
    required this.initialWeight,
  });

  final double initialWeight;

  @override
  State<ActiveWorkoutWeightEditorDialog> createState() =>
      _ActiveWorkoutWeightEditorDialogState();
}

class _ActiveWorkoutWeightEditorDialogState
    extends State<ActiveWorkoutWeightEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: _formatWeight(widget.initialWeight),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? _parseWeight(String? input) {
    final normalized = input?.trim().replaceAll(',', '.');
    final weight = normalized == null ? null : double.tryParse(normalized);
    if (weight == null || !weight.isFinite || weight < 0) return null;
    return weight;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_parseWeight(_controller.text));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit weight'),
    content: Form(
      key: _formKey,
      child: TextFormField(
        key: const ValueKey('weightInput'),
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Weight (kg)',
          suffixText: 'kg',
        ),
        validator: (value) => _parseWeight(value) == null
            ? 'Enter a valid non-negative weight.'
            : null,
        onFieldSubmitted: (_) => _save(),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('CANCEL'),
      ),
      FilledButton(
        key: const ValueKey('saveWeight'),
        onPressed: _save,
        child: const Text('SAVE'),
      ),
    ],
  );
}

class _SetValueStepper extends StatelessWidget {
  const _SetValueStepper({
    super.key,
    required this.value,
    required this.decreaseKey,
    required this.increaseKey,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String value;
  final Key decreaseKey;
  final Key increaseKey;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _StepperButton(
        key: decreaseKey,
        label: 'Decrease',
        icon: Icons.remove,
        onTap: onDecrease,
      ),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: const TextStyle(
            color: ActiveWorkoutColors.onSurface,
            fontFamily: 'monospace',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      _StepperButton(
        key: increaseKey,
        label: 'Increase',
        icon: Icons.add,
        onTap: onIncrease,
      ),
    ],
  );
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: Material(
      color: ActiveWorkoutColors.surface,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 28,
          height: 34,
          child: Center(
            child: Icon(icon, size: 14, color: ActiveWorkoutColors.onSurface),
          ),
        ),
      ),
    ),
  );
}

class _TableLabel extends StatelessWidget {
  const _TableLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      color: ActiveWorkoutColors.onSurfaceVariant,
      fontFamily: 'monospace',
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
    ),
  );
}

class ActiveWorkoutColors {
  static const background = Color(0xFF0F141B);
  static const surface = Color(0xFF1B2027);
  static const surfaceLow = Color(0xFF171C23);
  static const surfaceHigh = Color(0xFF252A32);
  static const surfaceHighest = Color(0xFF30353D);
  static const primary = Color(0xFF39FF14);
  static const onPrimary = Color(0xFF107100);
  static const onSurface = Color(0xFFDEE2EC);
  static const onSurfaceVariant = Color(0xFFBACCB0);
  static const error = Color(0xFFFFB4AB);
}
