import { BASES } from "../shared/arena";
import type { Mode, Seat, TeamId } from "../shared/teams";

export class Roster {
  private seats = new Map<string, Seat>();

  constructor(readonly mode: Mode) {
    if (mode.teams > BASES.length) throw new Error(`Arena has ${BASES.length} bases but mode needs ${mode.teams}`);
  }

  get isEmpty(): boolean {
    return this.seats.size === 0;
  }

  join(playerId: string): Seat | null {
    const team = this.openTeam();
    if (team === null) return null;
    const seat = { team, slot: this.freeSlot(team) };
    this.seats.set(playerId, seat);
    return seat;
  }

  leave(playerId: string): void {
    this.seats.delete(playerId);
  }

  private membersOf(team: TeamId): Seat[] {
    return [...this.seats.values()].filter((seat) => seat.team === team);
  }

  private openTeam(): TeamId | null {
    let best: TeamId | null = null;
    let bestCount = this.mode.playersPerTeam;
    for (let team = 0; team < this.mode.teams; team++) {
      const count = this.membersOf(team).length;
      if (count < bestCount) {
        best = team;
        bestCount = count;
      }
    }
    return best;
  }

  private freeSlot(team: TeamId): number {
    const taken = new Set(this.membersOf(team).map((seat) => seat.slot));
    let slot = 0;
    while (taken.has(slot)) slot++;
    return slot;
  }
}
