import { ARENA, RIVER_CENTER_Y, RIVER_SEGMENTS } from "../shared/arena";
import type { Unit } from "./Unit";

export function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

export function keepInArena(unit: Unit): void {
  const r = unit.stats.radius;
  unit.x = clamp(unit.x, r, ARENA.width - r);
  unit.y = clamp(unit.y, r, ARENA.height - r);
}

export function pushOutOfRiver(unit: Unit): void {
  const r = unit.stats.radius;
  for (const water of RIVER_SEGMENTS) {
    const closestX = clamp(unit.x, water.left, water.right);
    const closestY = clamp(unit.y, water.top, water.bottom);
    const dx = unit.x - closestX;
    const dy = unit.y - closestY;
    const distanceSq = dx * dx + dy * dy;
    if (distanceSq >= r * r) continue;

    if (distanceSq === 0) {
      unit.y = unit.y < RIVER_CENTER_Y ? water.top - r : water.bottom + r;
      continue;
    }
    const distance = Math.sqrt(distanceSq);
    const push = (r - distance) / distance;
    unit.x += dx * push;
    unit.y += dy * push;
  }
}

export function separateUnits(units: readonly Unit[]): void {
  for (let i = 0; i < units.length; i++) {
    for (let j = i + 1; j < units.length; j++) {
      const a = units[i];
      const b = units[j];
      const minDistance = a.stats.radius + b.stats.radius;
      let dx = b.x - a.x;
      let dy = b.y - a.y;
      let distance = Math.hypot(dx, dy);
      if (distance >= minDistance) continue;

      if (distance === 0) {
        dx = 1;
        dy = 0;
        distance = 1;
      }
      const push = (minDistance - Math.min(distance, minDistance)) / 2;
      const nx = dx / distance;
      const ny = dy / distance;
      a.x -= nx * push;
      a.y -= ny * push;
      b.x += nx * push;
      b.y += ny * push;
    }
  }
}
