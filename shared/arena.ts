import type { TeamId } from "./teams";

export interface Point {
  x: number;
  y: number;
}

export interface Rect {
  left: number;
  right: number;
  top: number;
  bottom: number;
}

export const ARENA = { width: 540, height: 960 };

export const TICK_RATE = 30;

export const RIVER = { top: 460, bottom: 500 };
export const RIVER_CENTER_Y = (RIVER.top + RIVER.bottom) / 2;

export const BRIDGES: Rect[] = [
  { left: 60, right: 120, top: RIVER.top, bottom: RIVER.bottom },
  { left: 420, right: 480, top: RIVER.top, bottom: RIVER.bottom },
];

export interface Base {
  tower: Point;
  deployZone: Rect;
}

export const BASES: Base[] = [
  {
    tower: { x: ARENA.width / 2, y: ARENA.height - 100 },
    deployZone: { left: 0, right: ARENA.width, top: RIVER.bottom, bottom: ARENA.height },
  },
  {
    tower: { x: ARENA.width / 2, y: 100 },
    deployZone: { left: 0, right: ARENA.width, top: 0, bottom: RIVER.top },
  },
];

export const RIVER_SEGMENTS: Rect[] = (() => {
  const segments: Rect[] = [];
  let x = 0;
  for (const bridge of [...BRIDGES].sort((a, b) => a.left - b.left)) {
    if (bridge.left > x) segments.push({ left: x, right: bridge.left, top: RIVER.top, bottom: RIVER.bottom });
    x = bridge.right;
  }
  if (x < ARENA.width) segments.push({ left: x, right: ARENA.width, top: RIVER.top, bottom: RIVER.bottom });
  return segments;
})();

export function canDeployAt(team: TeamId, x: number, y: number, radius: number): boolean {
  const zone = BASES[team]?.deployZone;
  if (!zone) return false;
  return x - radius >= zone.left && x + radius <= zone.right && y - radius >= zone.top && y + radius <= zone.bottom;
}
