import { ARENA, canDeployAt, type Side } from "../shared/arena";
import type { UnitSnapshot } from "../shared/protocol";
import { getStats, type UnitType } from "../shared/units";
import { clamp, keepInArena, pushOutOfRiver, separateUnits } from "./physics";
import { Unit } from "./Unit";

const MAX_UNITS = 200;

export class Match {
  private units = new Map<number, Unit>();
  private nextId = 1;

  spawn(type: UnitType, side: Side, x: number, y: number): boolean {
    if (this.units.size >= MAX_UNITS) return false;

    const { radius } = getStats(type);
    if (!canDeployAt(side, y, radius)) return false;

    const unit = new Unit(
      this.nextId++,
      type,
      side,
      clamp(x, radius, ARENA.width - radius),
      clamp(y, radius, ARENA.height - radius),
    );
    this.units.set(unit.id, unit);
    return true;
  }

  tick(dt: number): void {
    const units = [...this.units.values()];

    for (const unit of units) {
      if (unit.isAlive) unit.update(dt, units);
    }

    for (const unit of units) {
      if (!unit.isAlive) this.units.delete(unit.id);
    }

    const survivors = [...this.units.values()];
    separateUnits(survivors);
    for (const unit of survivors) {
      keepInArena(unit);
      pushOutOfRiver(unit);
    }
  }

  snapshot(): UnitSnapshot[] {
    return [...this.units.values()].map((unit) => unit.toSnapshot());
  }

  clear(): void {
    this.units.clear();
  }
}
