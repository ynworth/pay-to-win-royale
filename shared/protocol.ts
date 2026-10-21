import type { Side } from "./arena";
import type { UnitType } from "./units";

export interface UnitSnapshot {
  id: number;
  type: UnitType;
  side: Side;
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
  welcome: (info: { side: Side | null }) => void;
  state: (units: UnitSnapshot[]) => void;
}

export interface ClientToServerEvents {
  spawn: (request: SpawnRequest) => void;
}
