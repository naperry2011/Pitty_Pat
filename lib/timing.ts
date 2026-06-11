export const TIMING = {
  endTurnDelay: 400,   // ms between an action resolving and the turn passing
  aiThinkDelay: 1200,  // ms before the AI acts
  dealStagger: 80,     // ms between dealt cards
} as const;
