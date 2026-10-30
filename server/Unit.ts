// add homeless emote
import { BASES, type Point } from "../shared/arena";
import type { UnitSnapshot } from "../shared/protocol";
import type { TeamId } from "../shared/teams";
import { getStats, type UnitStats, type UnitType } from "../shared/units";
import { nextWaypoint } from "./pathing";

export class Unit {
  readonly stats: UnitStats;
  hp: number;
  private attackCooldown = 0;

  constructor(
    readonly id: number,
    readonly type: UnitType,
    readonly team: TeamId,
    public x: number,
    public y: number,
  ) {
    this.stats = getStats(type);
    this.hp = this.stats.maxHp;
  }

  get isAlive(): boolean {
    return this.hp > 0;
  }

  update(dt: number, units: readonly Unit[]): void {
    this.attackCooldown = Math.max(0, this.attackCooldown - dt);

    const target = this.findTarget(units);
    if (target && this.edgeDistanceTo(target) <= this.stats.range) {
      this.attack(target);
    } else {
      this.moveToward(target ?? this.nearestEnemyTower(), dt);
    }
  }

  edgeDistanceTo(other: Unit): number {
    return Math.hypot(other.x - this.x, other.y - this.y) - this.stats.radius - other.stats.radius;
  }

  toSnapshot(): UnitSnapshot {
    return { id: this.id, type: this.type, team: this.team, x: Math.round(this.x), y: Math.round(this.y), hp: this.hp };
  }

  private findTarget(units: readonly Unit[]): Unit | null {
    let best: Unit | null = null;
    let bestDistance = Infinity;
    for (const other of units) {
      if (other.team === this.team || !other.isAlive) continue;
      const distance = this.edgeDistanceTo(other);
      if (distance < bestDistance) {
        best = other;
        bestDistance = distance;
      }
    }
    return best;
  }

  private nearestEnemyTower(): Point {
    let best: Point = this;
    let bestDistance = Infinity;
    BASES.forEach(({ tower }, team) => {
      if (team === this.team) return;
      const distance = Math.hypot(tower.x - this.x, tower.y - this.y);
      if (distance < bestDistance) {
        best = tower;
        bestDistance = distance;
      }
    });
    return best;
  }

  private attack(target: Unit): void {
    if (this.attackCooldown > 0) return;
    target.hp = Math.max(0, target.hp - this.stats.damage);
    this.attackCooldown = this.stats.attackInterval;
  }

  private moveToward(destination: Point, dt: number): void {
    const waypoint = nextWaypoint(this, this.stats.radius, destination);
    const dx = waypoint.x - this.x;
    const dy = waypoint.y - this.y;
    const distance = Math.hypot(dx, dy);
    if (distance < 0.5) return;

    const step = Math.min(this.stats.speed * dt, distance);
    this.x += (dx / distance) * step;
    this.y += (dy / distance) * step;
  }
}
