import { GameObjects, type Scene } from "phaser";
import type { Side } from "../shared/arena";
import type { UnitSnapshot } from "../shared/protocol";
import { getStats } from "../shared/units";

export const SIDE_COLORS: Record<Side, number> = { bottom: 0x2266ff, top: 0xff3333 };

const HP_BAR_HEIGHT = 4;

const SMOOTHING_MS = 50;

export class UnitView {
  private container: GameObjects.Container;
  private hpFill: GameObjects.Rectangle;
  private targetX: number;
  private targetY: number;
  private readonly maxHp: number;

  constructor(scene: Scene, unit: UnitSnapshot) {
    const stats = getStats(unit.type);
    const size = stats.radius * 2;
    this.maxHp = stats.maxHp;
    this.targetX = unit.x;
    this.targetY = unit.y;

    const body = scene.add.rectangle(0, 0, size, size, stats.color).setStrokeStyle(3, SIDE_COLORS[unit.side]);
    const barY = -stats.radius - 6;
    const hpBack = scene.add.rectangle(-stats.radius, barY, size, HP_BAR_HEIGHT, 0x000000).setOrigin(0, 0.5);
    this.hpFill = scene.add.rectangle(-stats.radius, barY, size, HP_BAR_HEIGHT, 0x44ff44).setOrigin(0, 0.5);

    this.container = scene.add.container(unit.x, unit.y, [body, hpBack, this.hpFill]);
    this.apply(unit);
  }

  apply(unit: UnitSnapshot): void {
    this.targetX = unit.x;
    this.targetY = unit.y;
    this.hpFill.scaleX = unit.hp / this.maxHp;
  }

  update(deltaMs: number): void {
    const t = 1 - Math.exp(-deltaMs / SMOOTHING_MS);
    this.container.x += (this.targetX - this.container.x) * t;
    this.container.y += (this.targetY - this.container.y) * t;
  }

  destroy(): void {
    this.container.destroy();
  }
}
