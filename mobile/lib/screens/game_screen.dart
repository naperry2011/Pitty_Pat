import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../audio/sound_effects.dart';
import '../cards/card_back.dart';
import '../game/ai_player.dart';
import '../game/game_controller.dart';
import '../game/game_engine.dart';
import '../game/models.dart';
import '../game/personalities.dart';
import '../game/tutorial.dart';
import '../game_ui/confetti.dart';
import '../game_ui/flying_card.dart';
import '../game_ui/table_pieces.dart';
import '../game_ui/transitions.dart';
import '../profile/daily.dart';
import '../profile/profile_store.dart';
import '../profile/progression.dart';
import '../settings/settings_store.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/felt_table.dart';
import '../widgets/playful_background.dart';
import '../widgets/playful_button.dart';
import '../widgets/win_pips.dart';
import 'settings_sheet.dart';
import 'setup_screen.dart';

// Port of components/game/GameBoard.tsx.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.difficulty,
    required this.matchTarget,
    this.opponents = 1,
    this.dailyDate,
    @visibleForTesting this.controller,
    @visibleForTesting this.sounds,
    @visibleForTesting this.chatRandom,
  }) : isTutorial = false;

  // Daily challenge: one round against Sharp, dealt from the date's seed so
  // every player gets the same opening.
  const GameScreen.daily({
    super.key,
    required DateTime date,
    this.controller,
    this.sounds,
    this.chatRandom,
  }) : dailyDate = date,
       difficulty = AIDifficulty.hard,
       matchTarget = 1,
       opponents = 1,
       isTutorial = false;

  // First-run tutorial: a scripted hand with coaching; never recorded.
  const GameScreen.tutorial({
    super.key,
    this.controller,
    this.sounds,
    this.chatRandom,
  }) : dailyDate = null,
       difficulty = AIDifficulty.easy,
       matchTarget = 1,
       opponents = 1,
       isTutorial = true;

  final AIDifficulty difficulty;
  final int matchTarget;
  final int opponents; // computer opponents, 1-3
  final DateTime? dailyDate;
  final bool isTutorial;
  final GameController? controller;
  final SoundPlayer? sounds;
  final math.Random? chatRandom; // chatter dice, injectable for tests

  bool get isDaily => dailyDate != null;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Who sits at the table. The daily pick is seeded so everyone meets the same
  // opponent; the tutorial always seats friendly Rosie.
  late final List<Personality> _cast = widget.isTutorial
      ? [personalityByName('Rosie')]
      : pickOpponents(
          widget.difficulty,
          widget.opponents,
          widget.isDaily
              ? math.Random(dailySeed(widget.dailyDate!))
              : math.Random(),
        );

  late final GameController _game =
      widget.controller ??
      GameController(
        difficulty: widget.difficulty,
        matchTarget: widget.matchTarget,
        opponentNames: [for (final p in _cast) p.name],
        random: widget.isDaily
            ? math.Random(dailySeed(widget.dailyDate!))
            : null,
        initialState: widget.isTutorial
            ? tutorialGameState(opponentName: _cast.first.name)
            : null,
      );
  late final SoundPlayer _sounds = widget.sounds ?? defaultSoundPlayer;
  MatchSummary? _summary; // rewards for the match just finished

  // AI player id -> personality, for whoever at the table is in the roster.
  late final Map<String, Personality> _personas = {
    for (final p in _game.state.players)
      if (p.isAI) p.id: ?roster.where((r) => r.name == p.name).firstOrNull,
  };
  late final math.Random _chatRandom = widget.chatRandom ?? math.Random();
  ({String playerId, String line, int id})? _bubble;
  int _bubbleSeq = 0;
  Timer? _bubbleTimer;
  static const _bubbleDuration = Duration(milliseconds: 2200);

  // Presentation state only: read from state transitions, never fed back.
  late GameState _prev; // set in initState, before any change can arrive
  int _dealId = 0;
  final List<CardFlight> _flights = [];
  ({int id, int count})? _confetti;
  int _confettiSeq = 0;

  // Cached from the last build so the transition listener needn't look them up.
  GameSettings _settings = const GameSettings();
  bool _reduceMotion = false;
  double _tableCard = 80;

  final _stackKey = GlobalKey();
  final _deckKey = GlobalKey();
  final _discardKey = GlobalKey();
  final _humanCardKeys = <String, GlobalKey>{};
  final _aiCardKeys = <String, GlobalKey>{};
  final _seatLinks = <String, LayerLink>{};

  @override
  void initState() {
    super.initState();
    _prev = _game.state;
    _game.addListener(_onGameChanged);
    // The opening deal gets the shuffle cue too (web: placeholder -> playing).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_settings.soundMuted) _sounds.play(SoundCue.shuffle);
    });
  }

  @override
  void dispose() {
    _bubbleTimer?.cancel();
    _game.removeListener(_onGameChanged);
    _game.dispose();
    super.dispose();
  }

  // Runs synchronously on each state change, before the widget tree rebuilds,
  // so the card that just left a hand can still be measured.
  void _onGameChanged() {
    final next = _game.state;
    final t = StateTransition(_prev, next);
    _prev = next;

    if (!_settings.soundMuted) {
      for (final cue in t.cues) {
        _sounds.play(cue);
      }
    }

    _recordResults(t);

    if (t.isNewDeal) {
      _bubbleTimer?.cancel();
      setState(() {
        _dealId++;
        _flights.clear();
        _summary = null;
        _bubble = null;
      });
      return;
    }

    if (_settings.chatter) _maybeSpeak(t);

    final arrival = t.discardArrival;
    if (arrival != null && !_reduceMotion) _launchFlight(arrival);

    final celebrate = t.humanWon && t.prev.phase != next.phase;
    if (celebrate && !_reduceMotion) {
      setState(
        () => _confetti = (
          id: ++_confettiSeq,
          count: next.phase == GamePhase.gameEnd ? 120 : 50,
        ),
      );
    }
  }

  // One bubble at a time; round results replace whatever is showing.
  void _maybeSpeak(StateTransition t) {
    final r = reactionFor(t, _personas, _chatRandom);
    if (r == null || (_bubble != null && !r.important)) return;
    _bubbleTimer?.cancel();
    setState(
      () => _bubble = (playerId: r.playerId, line: r.line, id: ++_bubbleSeq),
    );
    _bubbleTimer = Timer(_bubbleDuration, () {
      if (mounted) setState(() => _bubble = null);
    });
  }

  // Rounds count as they finish; rewards are paid only when a match ends.
  void _recordResults(StateTransition t) {
    final profile = ProfileScope.maybeRead(context);
    final ended =
        t.prev.phase == GamePhase.playing &&
        (t.next.phase == GamePhase.roundEnd ||
            t.next.phase == GamePhase.gameEnd);
    if (profile == null || !ended || widget.isTutorial) return;

    profile.recordRound(
      widget.difficulty,
      won: t.humanWon,
      isDaily: widget.isDaily,
    );
    if (t.next.phase != GamePhase.gameEnd) return;

    final human = t.next.players.firstWhere((p) => !p.isAI);
    final opponents = t.next.players.where((p) => p.isAI).toList();
    final summary = profile.recordMatch(
      MatchOutcome(
        difficulty: widget.difficulty,
        matchTarget: t.next.matchTarget,
        won: t.humanWon,
        roundsWon: human.wins,
        roundsLost: opponents.fold(0, (a, p) => a + p.wins),
        isDaily: widget.isDaily,
        opponents: opponents.length,
      ),
    );
    setState(() => _summary = summary);
  }

  void _launchFlight(DiscardArrival arrival) {
    final fromKey = switch (arrival.source) {
      DiscardSource.humanHand => _humanCardKeys[arrival.card.id],
      DiscardSource.aiHand => _aiCardKeys[arrival.card.id],
      DiscardSource.deck => _deckKey,
    };
    final from = _rectOf(fromKey);
    final to = _rectOf(_discardKey);
    if (from == null || to == null) return;

    Rect cardRect(Rect r) => Rect.fromCenter(
      center: r.center,
      width: _tableCard,
      height: _tableCard * 1.5,
    );
    setState(
      () => _flights.add(
        CardFlight(
          card: arrival.card,
          from: arrival.source == DiscardSource.deck ? cardRect(from) : from,
          to: cardRect(to),
          flip: arrival.source != DiscardSource.humanHand,
          backStyle: _settings.cardBack,
        ),
      ),
    );
  }

  Rect? _rectOf(GlobalKey? key) {
    final box = key?.currentContext?.findRenderObject() as RenderBox?;
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stack == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero, ancestor: stack) & box.size;
  }

  void _changeSettings() => Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(builder: (_) => const SetupScreen()),
  );

  // Finishing or skipping the tutorial marks it done and goes to match setup.
  void _finishTutorial() {
    final settings = SettingsScope.of(context);
    settings.update(settings.settings.copyWith(tutorialDone: true));
    _changeSettings();
  }

  @override
  Widget build(BuildContext context) {
    _settings = SettingsScope.of(context).settings;
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    final backStyle = _settings.cardBack;
    final animate = !_reduceMotion;

    return Scaffold(
      body: PlayfulBackground(
        child: ListenableBuilder(
          listenable: _game,
          builder: (context, _) {
            final s = _game.state;
            final human = s.players.firstWhere((p) => !p.isAI);
            final opponents = s.players.where((p) => p.isAI).toList();
            final humanWon = s.winner == human.id;

            return Stack(
              key: _stackKey,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _game.clearSelection,
                  child: SafeArea(
                    child: LayoutBuilder(
                      builder: (context, box) {
                        // Cards scale with both width and height so short phones still fit.
                        final handCard = [
                          76.0,
                          (box.maxWidth - 24 - 40) / 5,
                          box.maxHeight * 0.1,
                        ].reduce(math.min);
                        final tableCard = [
                          84.0,
                          box.maxWidth / 4.4,
                          box.maxHeight * 0.1,
                        ].reduce(math.min);
                        _tableCard = tableCard;
                        // Seats share the width; crowded seats overlap their cards.
                        final seatWidth =
                            (box.maxWidth - 24 - (opponents.length - 1) * 8) /
                            opponents.length;
                        final crowded = opponents.length > 1;
                        final aiCard = crowded
                            ? math.min(40.0, (seatWidth - 16) / 2.8)
                            : math.min(52.0, handCard * 0.7);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              _Header(
                                humanWins: human.wins,
                                target: s.matchTarget,
                                onSettings: () => showSettingsSheet(context),
                                onSkipTutorial: widget.isTutorial
                                    ? _finishTutorial
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              if (widget.isTutorial)
                                _CoachBubble(
                                  text: tutorialHint(
                                    s,
                                    isFirstTurn: s.discardPile.length == 1,
                                  ),
                                )
                              else
                                _StatusBanner(state: s, humanWon: humanWon),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (
                                    var i = 0;
                                    i < opponents.length;
                                    i++
                                  ) ...[
                                    if (i > 0) const SizedBox(width: 8),
                                    Expanded(
                                      // Bubbles follow this link from the overlay layer.
                                      child: CompositedTransformTarget(
                                        link: _seatLinks.putIfAbsent(
                                          opponents[i].id,
                                          LayerLink.new,
                                        ),
                                        child: _OpponentSeat(
                                          player: opponents[i],
                                          persona: _personas[opponents[i].id],
                                          active:
                                              s.phase == GamePhase.playing &&
                                              s.currentPlayer.id ==
                                                  opponents[i].id,
                                          target: s.matchTarget,
                                          hand: HandView(
                                            cards: opponents[i].hand,
                                            cardWidth: aiCard,
                                            backStyle: backStyle,
                                            faceDown: true,
                                            gap: crowded
                                                ? -aiCard * 0.55
                                                : null,
                                            dealId: _dealId,
                                            dealFromAbove: false,
                                            animate: animate,
                                            keyFor: (id) => _aiCardKeys
                                                .putIfAbsent(id, GlobalKey.new),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: FeltTable(
                                  felt: _settings.felt,
                                  // Fills the felt; the contents scale down rather than overflow on short phones.
                                  child: SizedBox.expand(
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: _TableCenter(
                                          game: _game,
                                          cardWidth: tableCard,
                                          backStyle: backStyle,
                                          deckKey: _deckKey,
                                          discardKey: _discardKey,
                                          hiddenDiscardId: _flights.isEmpty
                                              ? null
                                              : _flights.last.card.id,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _HandLabel(
                                'Your hand',
                                active: _game.isHumanTurn,
                                color: AppColors.coral,
                              ),
                              const SizedBox(height: 2),
                              HandView(
                                cards: human.hand,
                                cardWidth: handCard,
                                backStyle: backStyle,
                                playableIds: {
                                  for (final c in human.hand)
                                    if (_game.isPlayable(c)) c.id,
                                },
                                selectedId: s.selectedCardId,
                                onCardTap: _game.tapCard,
                                dealId: _dealId,
                                animate: animate,
                                keyFor: (id) => _humanCardKeys.putIfAbsent(
                                  id,
                                  GlobalKey.new,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 56,
                                child: s.phase == GamePhase.roundEnd
                                    ? PlayfulButton(
                                        label: 'Next round',
                                        icon: Icons.replay_rounded,
                                        onPressed: _game.nextRound,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Speech bubbles ride above the felt, pinned under their seat.
                if (_bubble case final b?)
                  if (_seatLinks[b.playerId] case final link?)
                    CompositedTransformFollower(
                      link: link,
                      showWhenUnlinked: false,
                      targetAnchor: Alignment.bottomCenter,
                      followerAnchor: Alignment.topCenter,
                      child: IgnorePointer(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: TweenAnimationBuilder<double>(
                            key: ValueKey(b.id),
                            tween: Tween(begin: 0.6, end: 1),
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutBack,
                            builder: (context, scale, child) => Transform.scale(
                              scale: scale,
                              alignment: Alignment.topCenter,
                              child: child,
                            ),
                            child: _SpeechBubble(
                              text: b.line,
                              color:
                                  _personas[b.playerId]?.color ??
                                  const Color(0xFF5F7ADB),
                            ),
                          ),
                        ),
                      ),
                    ),
                if (s.phase == GamePhase.gameEnd)
                  _MatchOverDialog(
                    humanWon: humanWon,
                    players: s.players,
                    winnerName:
                        s.players
                            .where((p) => p.id == s.winner)
                            .firstOrNull
                            ?.name ??
                        '',
                    target: s.matchTarget,
                    summary: _summary,
                    isDaily: widget.isDaily,
                    isTutorial: widget.isTutorial,
                    onTutorialDone: _finishTutorial,
                    onRematch: _game.rematch,
                    onChangeSettings: _changeSettings,
                    onDone: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                for (final flight in _flights)
                  FlyingCard(
                    key: ObjectKey(flight),
                    flight: flight,
                    onDone: () => setState(() => _flights.remove(flight)),
                  ),
                if (_confetti case final c?)
                  Positioned.fill(
                    child: ConfettiBurst(
                      key: ValueKey(c.id),
                      count: c.count,
                      style: _settings.celebration,
                      onDone: () => setState(() => _confetti = null),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.humanWins,
    required this.target,
    required this.onSettings,
    this.onSkipTutorial,
  });

  final int humanWins;
  final int target;
  final VoidCallback onSettings;
  final VoidCallback? onSkipTutorial; // set only in the tutorial

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton.filledTonal(
        tooltip: 'Home',
        onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        icon: const Icon(Icons.home_rounded),
      ),
      IconButton.filledTonal(
        tooltip: 'Settings',
        onPressed: onSettings,
        icon: const Icon(Icons.settings_rounded),
      ),
      const Spacer(),
      if (onSkipTutorial != null)
        TextButton.icon(
          onPressed: onSkipTutorial,
          icon: const Icon(Icons.skip_next_rounded),
          label: const Text('Skip tutorial'),
        )
      else
        // Opponents show their own scores in their seats.
        ScoreChip(
          label: 'You',
          wins: humanWins,
          target: target,
          color: AppColors.coral,
        ),
    ],
  );
}

// One computer opponent: name, round-win pips, turn highlight and face-down hand.
class _OpponentSeat extends StatelessWidget {
  const _OpponentSeat({
    required this.player,
    required this.active,
    required this.target,
    required this.hand,
    this.persona,
  });

  final Player player;
  final bool active;
  final int target;
  final Widget hand;
  final Personality? persona;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 220),
    padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: active ? 0.75 : 0.45),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: active ? const Color(0xFF5F7ADB) : Colors.transparent,
        width: 2,
      ),
    ),
    child: Column(
      children: [
        Semantics(
          container: true,
          label:
              '${player.name}, ${player.hand.length} cards${active ? ', thinking' : ''}',
          excludeSemantics: true,
          // Name above pips: a first-to-10 row of pips wraps instead of overflowing.
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Avatar(
                    name: player.name,
                    color: persona?.color ?? const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      active ? '${player.name}...' : player.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: active
                            ? const Color(0xFF5F7ADB)
                            : const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              WinPips(
                wins: player.wins,
                target: target,
                color: const Color(0xFF475569),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        hand,
      ],
    ),
  );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 20,
    height: 20,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    child: Text(
      name.isEmpty ? '?' : name[0],
      style: TextStyle(
        fontFamily: displayFontFamily(context),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1,
      ),
    ),
  );
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    container: true,
    label: text,
    excludeSemantics: true,
    child: Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: 2),
          boxShadow: AppShadows.raised,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ),
    ),
  );
}

// Tutorial coaching, shown where the status message normally sits.
class _CoachBubble extends StatelessWidget {
  const _CoachBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    container: true,
    label: text,
    excludeSemantics: true,
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: Container(
        key: ValueKey(text),
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppShadows.raised,
        ),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_rounded, color: AppColors.gold),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.state, required this.humanWon});

  final GameState state;
  final bool humanWon;

  String get _winnerName =>
      state.players.where((p) => p.id == state.winner).firstOrNull?.name ?? '';

  @override
  Widget build(BuildContext context) {
    final roundOver = state.phase == GamePhase.roundEnd;

    return SizedBox(
      height: 48,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          // Messages crossfade (scaling two overlapping texts garbles them);
          // only the round-over banner pops in.
          transitionBuilder: (child, anim) =>
              child.key == const ValueKey('round-over')
              ? ScaleTransition(scale: anim, child: child)
              : FadeTransition(opacity: anim, child: child),
          child: roundOver
              ? Container(
                  key: const ValueKey('round-over'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: humanWon
                          ? const [AppColors.gold, AppColors.sunny]
                          : const [AppColors.softPurple, Color(0xFF5F7ADB)],
                    ),
                    boxShadow: AppShadows.floating,
                  ),
                  child: Text(
                    humanWon
                        ? 'Great job! You win the round!'
                        : '$_winnerName wins the round!',
                    style: TextStyle(
                      fontFamily: displayFontFamily(context),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: humanWon ? AppColors.ink : Colors.white,
                    ),
                  ),
                )
              : Container(
                  key: ValueKey(state.message),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    state.message,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _HandLabel extends StatelessWidget {
  const _HandLabel(this.label, {required this.active, required this.color});

  final String label;
  final bool active;
  final Color color;

  @override
  // Merged onto the inherited style so the theme's font (Inter) carries through.
  Widget build(BuildContext context) => AnimatedDefaultTextStyle(
    duration: const Duration(milliseconds: 250),
    style: DefaultTextStyle.of(context).style.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: active ? 15 : 13,
      color: active ? color : const Color(0xFF6B7280),
    ),
    child: Text(label),
  );
}

class _TableCenter extends StatelessWidget {
  const _TableCenter({
    required this.game,
    required this.cardWidth,
    required this.backStyle,
    required this.deckKey,
    required this.discardKey,
    this.hiddenDiscardId,
  });

  final GameController game;
  final double cardWidth;
  final CardBackStyle backStyle;
  final GlobalKey deckKey;
  final GlobalKey discardKey;
  final String? hiddenDiscardId;

  @override
  Widget build(BuildContext context) {
    final s = game.state;
    final canDraw = game.isHumanTurn;
    final canPlay =
        game.isHumanTurn &&
        findPlayableCards(s.players[0].hand, s.topDiscard).isNotEmpty;
    const label = TextStyle(
      color: Color(0xCCFFF8F0),
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                const Text('DRAW', style: label),
                const SizedBox(height: 8),
                DeckView(
                  key: deckKey,
                  count: s.deck.length,
                  cardWidth: cardWidth,
                  backStyle: backStyle,
                  onTap: canDraw ? game.drawCard : null,
                ),
              ],
            ),
            const SizedBox(width: 40),
            Column(
              children: [
                const Text('DISCARD', style: label),
                const SizedBox(height: 8),
                DiscardPileView(
                  key: discardKey,
                  cards: s.discardPile,
                  cardWidth: cardWidth,
                  hiddenId: hiddenDiscardId,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 36,
          child: canDraw
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: canPlay
                          ? const [AppColors.coral, AppColors.coralDeep]
                          : const [AppColors.mint, Color(0xFF2E9E8F)],
                    ),
                  ),
                  child: Text(
                    canPlay ? 'Tap a matching card!' : 'Tap the deck to draw',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

class _MatchOverDialog extends StatelessWidget {
  const _MatchOverDialog({
    required this.humanWon,
    required this.players,
    required this.winnerName,
    required this.target,
    required this.summary,
    required this.isDaily,
    required this.isTutorial,
    required this.onTutorialDone,
    required this.onRematch,
    required this.onChangeSettings,
    required this.onDone,
  });

  final bool humanWon;
  final List<Player> players;
  final String winnerName;
  final int target;
  final MatchSummary? summary;
  final bool isDaily;
  final bool isTutorial;
  final VoidCallback onTutorialDone;
  final VoidCallback onRematch;
  final VoidCallback onChangeSettings;
  final VoidCallback onDone;

  String get _title => isTutorial
      ? (humanWon ? "You're ready to play!" : "Nice try! You're ready.")
      : switch ((isDaily, humanWon)) {
          (true, true) => 'Daily challenge won!',
          (true, false) => 'Daily challenge done',
          (false, true) => 'You win the match!',
          (false, false) => '$winnerName wins the match!',
        };

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.6, end: 1),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 380),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppShadows.floating,
            ),
            child: Semantics(
              scopesRoute: true,
              explicitChildNodes: true,
              namesRoute: true,
              label: 'Match over',
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDaily
                          ? Icons.calendar_today_rounded
                          : Icons.emoji_events_rounded,
                      size: 56,
                      color: humanWon
                          ? AppColors.gold
                          : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: displayFontFamily(context),
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    if (isTutorial) ...[
                      const SizedBox(height: 8),
                      const Text(
                        "Match the rank, draw when you can't, and empty your hand first.",
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (!isDaily && !isTutorial) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          for (final p in players)
                            ScoreChip(
                              label: p.isAI ? p.name : 'You',
                              wins: p.wins,
                              target: target,
                              color: p.isAI
                                  ? const Color(0xFF475569)
                                  : AppColors.coral,
                            ),
                        ],
                      ),
                    ],
                    if (summary case final s?) ...[
                      const SizedBox(height: 16),
                      _RewardsPanel(summary: s),
                    ],
                    const SizedBox(height: 22),
                    if (isTutorial)
                      PlayfulButton(
                        label: "Let's play!",
                        icon: Icons.play_arrow_rounded,
                        onPressed: onTutorialDone,
                      )
                    else if (isDaily)
                      PlayfulButton(
                        label: 'Done',
                        icon: Icons.check_rounded,
                        onPressed: onDone,
                      )
                    else ...[
                      PlayfulButton(
                        label: 'Rematch',
                        icon: Icons.replay_rounded,
                        onPressed: onRematch,
                      ),
                      const SizedBox(height: 12),
                      PlayfulButton(
                        label: 'Change settings',
                        primary: false,
                        fontSize: 16,
                        onPressed: onChangeSettings,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _RewardsPanel extends StatelessWidget {
  const _RewardsPanel({required this.summary});

  final MatchSummary summary;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RewardChip(
                icon: Icons.monetization_on_rounded,
                color: AppColors.gold,
                label: '+${s.totalCoins}',
              ),
              const SizedBox(width: 12),
              _RewardChip(
                icon: Icons.bolt_rounded,
                color: AppColors.coral,
                label: '+${s.reward.xp} XP',
              ),
            ],
          ),
          if (s.streakBonus > 0) ...[
            const SizedBox(height: 6),
            Text(
              'Includes +${s.streakBonus} daily streak bonus',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
          if (s.leveledUp) ...[
            const SizedBox(height: 10),
            Text(
              'Level up! You reached level ${s.levelAfter}',
              style: TextStyle(
                fontFamily: displayFontFamily(context),
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.coralDeep,
              ),
            ),
          ],
          for (final a in s.unlocked) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.military_tech_rounded,
                  color: AppColors.gold,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Achievement: ${a.title} (+${a.coins})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: AppColors.ink,
        ),
      ),
    ],
  );
}
