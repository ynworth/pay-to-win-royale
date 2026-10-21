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

export type Side = "top" | "bottom";

export function opponentOf(side: Side): Side {
  return side === "top" ? "bottom" : "top";
}

export const ARENA = { width: 540, height: 960 };

export const TICK_RATE = 30;

export const RIVER = { top: 460, bottom: 500 };
export const RIVER_CENTER_Y = (RIVER.top + RIVER.bottom) / 2;

export const BRIDGES: Rect[] = [
  { left: 60, right: 120, top: RIVER.top, bottom: RIVER.bottom },
  { left: 420, right: 480, top: RIVER.top, bottom: RIVER.bottom },
];

export const TOWERS: Record<Side, Point> = {
  top: { x: ARENA.width / 2, y: 100 },
  bottom: { x: ARENA.width / 2, y: ARENA.height - 100 },
};

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

export function canDeployAt(side: Side, y: number, radius: number): boolean {
  return side === "top" ? y < RIVER.top - radius : y > RIVER.bottom + radius;
}
