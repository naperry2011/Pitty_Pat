import 'package:flutter/material.dart';

import '../profile/daily.dart';
import '../profile/profile_store.dart';
import '../profile/progression.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/playful_background.dart';
import '../widgets/screen_header.dart';
import '../widgets/playful_button.dart';
import 'game_screen.dart';

// Today's challenge, the current streak, and a month calendar of completed days.
class DailyScreen extends StatelessWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ProfileScope.of(context);
    final today = store.today;
    final done = store.dailyDoneToday;
    final wonToday = store.profile.dailyWon.contains(dateKey(today));
    final streak = store.dailyStreak;

    return Scaffold(
      body: PlayfulBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              const ScreenHeader(title: 'Daily Challenge'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: AppColors.coral,
                            size: 34,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$streak day${streak == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontFamily: displayFontFamily(context),
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'current streak',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'One round against Sharp. Everyone gets the same deal today.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Win: +40 coins  ·  Finish: +15 coins  ·  Streak: +${dailyStreakBonus(streak + (done ? 0 : 1))}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (done)
                      Text(
                        wonToday
                            ? 'You beat today\'s deal. Come back tomorrow!'
                            : 'Done for today. Come back tomorrow!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.feltDeep,
                        ),
                      )
                    else
                      PlayfulButton(
                        label: 'Play today\'s deal',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => GameScreen.daily(date: today),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _MonthCalendar(
                month: DateTime(today.year, today.month),
                today: today,
                completed: store.profile.dailyCompleted,
                won: store.profile.dailyWon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.month,
    required this.today,
    required this.completed,
    required this.won,
  });

  final DateTime month;
  final DateTime today;
  final Set<String> completed;
  final Set<String> won;

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June', //
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading =
        DateTime(month.year, month.month, 1).weekday % 7; // Sunday-first grid

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Text(
            '${_monthNames[month.month - 1]} ${month.year}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final d in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: [
              for (var i = 0; i < leading; i++) const SizedBox.shrink(),
              for (var day = 1; day <= daysInMonth; day++)
                _DayCell(
                  date: DateTime(month.year, month.month, day),
                  isToday: day == today.day,
                  done: completed.contains(
                    dateKey(DateTime(month.year, month.month, day)),
                  ),
                  won: won.contains(
                    dateKey(DateTime(month.year, month.month, day)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isToday,
    required this.done,
    required this.won,
  });

  final DateTime date;
  final bool isToday;
  final bool done;
  final bool won;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label:
        '${date.day}${done ? (won ? ', won' : ', completed') : ''}${isToday ? ', today' : ''}',
    excludeSemantics: true,
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: won
            ? AppColors.gold
            : done
            ? AppColors.mint
            : Colors.transparent,
        border: isToday ? Border.all(color: AppColors.coral, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${date.day}',
        style: TextStyle(
          fontWeight: isToday || done ? FontWeight.w800 : FontWeight.w500,
          color: done ? Colors.white : AppColors.ink,
        ),
      ),
    ),
  );
}
