import type { Seat, TeamId } from "./teams";
import type { UnitType } from "./units";

export interface UnitSnapshot {
  id: number;
  type: UnitType;
  team: TeamId;
  x: number;
  y: number;
  hp: number;
}

export interface SpawnRequest {
  type: UnitType;
  x: number;
  y: number;
}

export interface ServerToClientEvents {
  welcome: (info: { seat: Seat | null }) => void;
  state: (units: UnitSnapshot[]) => void;
}

export interface ClientToServerEvents {
  spawn: (request: SpawnRequest) => void;
}
