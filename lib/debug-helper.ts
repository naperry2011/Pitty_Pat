// Debug helper to log game state changes
export function logGameState(action: string, state: any) {
  if (typeof window !== 'undefined' && process.env.NODE_ENV === 'development') {
    console.group(`🎮 ${action}`);
    console.log('Current Player:', state.players[state.currentPlayerIndex]?.name);
    console.log('Turn Action:', state.turnAction);
    console.log('Phase:', state.phase);
    console.log('Top Discard:', state.discardPile[state.discardPile.length - 1]?.rank);
    console.log('Player Hand:', state.players[0]?.hand.map((c: any) => c.rank).join(', '));
    console.log('AI Hand:', state.players[1]?.hand.map((c: any) => c.rank).join(', '));
    console.groupEnd();
  }
}