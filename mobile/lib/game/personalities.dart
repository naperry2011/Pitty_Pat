import 'dart:math';
import 'dart:ui';

import '../game_ui/transitions.dart';
import 'ai_player.dart';
import 'models.dart';
import 'play_style.dart';

// Named computer opponents: table talk plus a play style. Each style stays
// close to its difficulty tier's miss rate (Sharp opponents never miss), so the
// tier still describes how hard the table is.

enum Moment { play, drawHit, drawMiss, lastCard, winRound, loseRound }

class Personality {
  const Personality(this.name, this.color, this.difficulty, this.lines,
      {required this.tagline, required this.style});

  final String name;
  final Color color;
  final AIDifficulty difficulty;
  final Map<Moment, List<String>> lines;
  final String tagline; // how they play, shown under their name
  final PlayStyle style;
}

const roster = <Personality>[
  // Chill
  Personality('Rosie', Color(0xFFFF8FA3), AIDifficulty.easy, {
    Moment.play: ['Ooh, I had one!', 'Look at that!', 'Lucky me!'],
    Moment.drawHit: ['Well would you look at that!', 'The deck loves me today!'],
    Moment.drawMiss: ['Oh, fiddlesticks.', 'Not this time!'],
    Moment.lastCard: ['One card left, sugar!', 'Almost there!'],
    Moment.winRound: ['Pat! I did it!', 'Well, how about that!'],
    Moment.loseRound: ['Good game, sweetie!', 'You got me fair and square.'],
  }, tagline: 'Strong finisher', style: PlayStyle(miss: 0.35, trait: Trait.closer)),
  Personality('Pops', Color(0xFF8D6E63), AIDifficulty.easy, {
    Moment.play: ['Still got it.', 'Back in my day...', 'Mm-hmm.'],
    Moment.drawHit: ['Ha! Old man luck!', 'Didn\'t even look.'],
    Moment.drawMiss: ['Eh, figures.', 'Hand me another.'],
    Moment.lastCard: ['Last one. Watch this.', 'Getting close now.'],
    Moment.winRound: ['That\'s how we did it in \'68!', 'Pops still got it!'],
    Moment.loseRound: ['You young folks are quick.', 'I let you have that one.'],
  }, tagline: 'Takes it slow', style: PlayStyle(miss: 0.4, thinkDelay: Duration(milliseconds: 1900))),
  Personality('Lulu', Color(0xFFBA68C8), AIDifficulty.easy, {
    Moment.play: ['Yay!', 'Match match match!', 'Ooh pretty!'],
    Moment.drawHit: ['No way!', 'It played itself!'],
    Moment.drawMiss: ['Aww.', 'Boo!'],
    Moment.lastCard: ['One left!!', 'Eek, so close!'],
    Moment.winRound: ['I WON!', 'Best day ever!'],
    Moment.loseRound: ['Rematch! Rematch!', 'You\'re so good!'],
  }, tagline: 'Sloppy if ahead', style: PlayStyle(miss: 0.3, thinkDelay: Duration(milliseconds: 700), trait: Trait.coasts)),
  // Clever
  Personality('Marcus', Color(0xFF42A5F5), AIDifficulty.medium, {
    Moment.play: ['Saw that coming.', 'Right on cue.', 'Calculated.'],
    Moment.drawHit: ['Even the deck agrees.', 'Clean.'],
    Moment.drawMiss: ['Noted.', 'Interesting.'],
    Moment.lastCard: ['One left. Your move.', 'Endgame.'],
    Moment.winRound: ['Too smooth.', 'Just like I planned.'],
    Moment.loseRound: ['Respect. Nicely played.', 'I\'ll remember that.'],
  }, tagline: 'Plays defense', style: PlayStyle(miss: 0.12, trait: Trait.focused)),
  Personality('Auntie Bev', Color(0xFFFFA726), AIDifficulty.medium, {
    Moment.play: ['Mm-hmm, baby.', 'Don\'t mind if I do.', 'Auntie\'s got one.'],
    Moment.drawHit: ['My, look at that!', 'Look at Auntie go!'],
    Moment.drawMiss: ['Child, please.', 'That deck is cold.'],
    Moment.lastCard: ['Auntie\'s almost out!', 'One more, honey.'],
    Moment.winRound: ["Pitty Pat! Read 'em and weep!", 'Auntie still runs this table!'],
    Moment.loseRound: ['Okay, I see you!', 'Don\'t get comfortable.'],
  }, tagline: 'Fights back', style: PlayStyle(miss: 0.12, thinkDelay: Duration(milliseconds: 1500), trait: Trait.steadies)),
  Personality('Theo', Color(0xFF26A69A), AIDifficulty.medium, {
    Moment.play: ['Nice.', 'There it is.', 'Got one.'],
    Moment.drawHit: ['Clutch draw!', 'Let\'s go!'],
    Moment.drawMiss: ['Brick.', 'Ugh.'],
    Moment.lastCard: ['Last card, heads up.', 'One to go.'],
    Moment.winRound: ['GG!', 'Easy work.'],
    Moment.loseRound: ['GG, you earned it.', 'Run it back.'],
  }, tagline: 'Tilts easily', style: PlayStyle(miss: 0.1, thinkDelay: Duration(milliseconds: 800), trait: Trait.tilts)),
  // Sharp
  Personality('Dee', Color(0xFFE84855), AIDifficulty.hard, {
    Moment.play: ['Keep up.', 'Next.', 'Too easy.'],
    Moment.drawHit: ['Of course.', 'Even the deck fears me.'],
    Moment.drawMiss: ['Doesn\'t matter.', 'Still ahead.'],
    Moment.lastCard: ['One card. Sweat.', 'This is over.'],
    Moment.winRound: ['Pat. Again.', 'Was there any doubt?'],
    Moment.loseRound: ['Hm. Lucky.', 'Enjoy it while it lasts.'],
  }, tagline: 'Lightning fast', style: PlayStyle(miss: 0, thinkDelay: Duration(milliseconds: 600))),
  Personality('Jada', Color(0xFF5F7ADB), AIDifficulty.hard, {
    Moment.play: ['Watch and learn.', 'Mine.', 'Boom.'],
    Moment.drawHit: ['Called it.', 'That\'s skill, actually.'],
    Moment.drawMiss: ['Whatever.', 'I\'ll allow it.'],
    Moment.lastCard: ['Last card, no pressure.', 'You hear that? That\'s the end.'],
    Moment.winRound: ['Undefeated energy.', 'Put it on the board!'],
    Moment.loseRound: ['Okay, that was good.', 'Bet. Next round.'],
  }, tagline: 'Never misses', style: PlayStyle(miss: 0, thinkDelay: Duration(milliseconds: 900))),
  Personality('Vince', Color(0xFF455A64), AIDifficulty.hard, {
    Moment.play: ['Mm.', 'Expected.', 'Proceed.'],
    Moment.drawHit: ['Probability favors me.', 'As planned.'],
    Moment.drawMiss: ['A minor setback.', 'Irrelevant.'],
    Moment.lastCard: ['One remains.', 'Checkmate approaches.'],
    Moment.winRound: ['Inevitable.', 'The numbers never lie.'],
    Moment.loseRound: ['An anomaly.', 'I will adjust.'],
  }, tagline: 'Patient pro', style: PlayStyle(miss: 0, thinkDelay: Duration(milliseconds: 1700))),
];

Personality personalityByName(String name) => roster.firstWhere((p) => p.name == name);

/// Picks [count] distinct opponents, preferring the difficulty's own pool.
List<Personality> pickOpponents(AIDifficulty difficulty, int count, Random rng) {
  final pool = roster.where((p) => p.difficulty == difficulty).toList()..shuffle(rng);
  final rest = roster.where((p) => p.difficulty != difficulty).toList()..shuffle(rng);
  return [...pool, ...rest].take(count).toList();
}

class Reaction {
  const Reaction(this.playerId, this.line, {this.important = false});
  final String playerId;
  final String line;
  final bool important; // round results override a bubble already showing
}

/// Who (if anyone) says what after a state transition. [rng] decides chance and
/// line choice; [personalities] maps AI player ids to their personality.
Reaction? reactionFor(StateTransition t, Map<String, Personality> personalities, Random rng) {
  String say(Personality p, Moment m) {
    final options = p.lines[m]!;
    return options[rng.nextInt(options.length)];
  }

  final next = t.next;
  if (t.prev.phase == GamePhase.playing && next.phase != GamePhase.playing) {
    final winner = personalities[next.winner];
    if (winner != null) {
      return Reaction(next.winner!, say(winner, Moment.winRound), important: true);
    }
    // The human won: one opponent takes it graciously (or not).
    final ids = personalities.keys.toList();
    if (ids.isEmpty) return null;
    final id = ids[rng.nextInt(ids.length)];
    return Reaction(id, say(personalities[id]!, Moment.loseRound), important: true);
  }

  final arrival = t.discardArrival;
  final mover = t.prev.currentPlayer;
  final p = personalities[mover.id];
  if (arrival == null || p == null) return null;

  if (arrival.source == DiscardSource.aiHand) {
    final left = next.players.firstWhere((x) => x.id == mover.id).hand.length;
    if (left == 1) return Reaction(mover.id, say(p, Moment.lastCard));
    return rng.nextDouble() < 0.35 ? Reaction(mover.id, say(p, Moment.play)) : null;
  }
  if (arrival.source == DiscardSource.deck) {
    final hit = arrival.card.rank == t.prev.topDiscard.rank;
    if (hit) return rng.nextDouble() < 0.6 ? Reaction(mover.id, say(p, Moment.drawHit)) : null;
    return rng.nextDouble() < 0.15 ? Reaction(mover.id, say(p, Moment.drawMiss)) : null;
  }
  return null;
}
