// The opponent ladder: beat each named opponent 1v1, in order, to unlock the
// next. Names match the personality roster (checked by tests).
const ladderOrder = [
  'Rosie',
  'Pops',
  'Lulu',
  'Marcus',
  'Auntie Bev',
  'Theo',
  'Dee',
  'Jada',
  'Vince',
];

const ladderMatchTarget = 3;

/// One-time coins for clearing rung [rung] (0-based); higher rungs pay more.
int ladderBonus(int rung) => 25 + 15 * rung;
