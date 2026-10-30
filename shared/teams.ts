export type TeamId = number;

export interface Seat {
  team: TeamId;
  slot: number;
}

export interface Mode {
  teams: number;
  playersPerTeam: number;
}

export const MODES = {
  "1v1": { teams: 2, playersPerTeam: 1 },
  "2v2": { teams: 2, playersPerTeam: 2 },
  "3v3": { teams: 2, playersPerTeam: 3 },
} satisfies Record<string, Mode>;
