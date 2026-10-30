import { GameObjects, type Scene } from "phaser";
import type { UnitSnapshot } from "../shared/protocol";
import { getStats } from "../shared/units";
import type { Perspective } from "./Perspective";

const HP_BAR_HEIGHT = 4;

const SMOOTHING_MS = 50;

export class UnitView {
  private container: GameObjects.Container;
  private hpFill: GameObjects.Rectangle;
  private targetX: number;
  private targetY: number;
  private readonly maxHp: number;

  constructor(
    scene: Scene,
    unit: UnitSnapshot,
    private readonly perspective: Perspective,
  ) {
    const stats = getStats(unit.type);
    const size = stats.radius * 2;
    this.maxHp = stats.maxHp;
    ({ x: this.targetX, y: this.targetY } = perspective.toScreen(unit));

    const body = scene.add.image(0, 0, unit.type).setDisplaySize(size, size);
    const barY = -stats.radius - 6;
    const hpBack = scene.add.rectangle(-stats.radius, barY, size, HP_BAR_HEIGHT, 0x000000).setOrigin(0, 0.5);
    this.hpFill = scene.add.rectangle(-stats.radius, barY, size, HP_BAR_HEIGHT, 0x44ff44).setOrigin(0, 0.5);

    this.container = scene.add.container(this.targetX, this.targetY, [body, hpBack, this.hpFill]);
    this.apply(unit);
  }

  apply(unit: UnitSnapshot): void {
    ({ x: this.targetX, y: this.targetY } = this.perspective.toScreen(unit));
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
