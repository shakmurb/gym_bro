# Gym Bro

Gym Bro includes a Workout Hub, Active Workout Tracker, Exercise Library, and
History & Analytics screen. The bottom navigation switches between the Hub,
Exercise Library, and History & Analytics; start an active workout from the
Hub's Start Workout button.

The Active Workout Tracker receives a `Workout` and shows its exercise cards
and sets. The Start button begins the total workout clock; completing a set
starts a rest using that exercise's recommended rest time. Rest can be adjusted
in 15-second increments or skipped, and the next set starts manually. Set
weights and reps can be adjusted inline in 2.5 kg and 1-rep increments. Pause,
resume, and reset are available throughout the workout. The Hub currently
passes a randomized hardcoded placeholder workout.

On Android, the app requests notification permission and exact-alarm access so
the rest-end alert can sound and vibrate while the app is backgrounded or the
screen is locked. If exact-alarm access is denied, the app shows a warning and
uses an inexact alarm where available. Device notification settings, Do Not
Disturb, and battery policies can still affect delivery.

Run the timer tests with `flutter test`. Background delivery should also be
checked on an Android device by starting a rest, locking the screen until it
ends, and returning to the app; the app recalculates the phase from the active
deadline when it resumes.
