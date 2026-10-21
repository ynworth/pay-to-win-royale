import { Scene, type GameObjects, type Input } from "phaser";
import { io, type Socket } from "socket.io-client";
import { BRIDGES, RIVER_SEGMENTS, TOWERS, type Side } from "../../shared/arena";
import type { ClientToServerEvents, ServerToClientEvents, UnitSnapshot } from "../../shared/protocol";
import type { UnitType } from "../../shared/units";
import { SIDE_COLORS, UnitView } from "../UnitView";

export class Game extends Scene {
  private socket!: Socket<ServerToClientEvents, ClientToServerEvents>;
  private views = new Map<number, UnitView>();
  private statusText!: GameObjects.Text;
  private selectedType: UnitType = "square";

  constructor() {
    super({ key: "Game" });
  }

  create(): void {
    this.drawArena();
    this.statusText = this.add.text(10, 10, "Connecting...", { fontSize: "20px", color: "#ffffff" }).setDepth(10);

    this.socket = io();
    this.socket.on("welcome", ({ side }) => this.showSide(side));
    this.socket.on("state", (units) => this.applyState(units));
    this.events.once("shutdown", () => this.socket.disconnect());

    this.input.on("pointerdown", (pointer: Input.Pointer) => {
      this.socket.emit("spawn", { type: this.selectedType, x: pointer.worldX, y: pointer.worldY });
    });
  }

  update(_time: number, deltaMs: number): void {
    for (const view of this.views.values()) view.update(deltaMs);
  }

  private drawArena(): void {
    for (const water of RIVER_SEGMENTS) {
      this.add
        .rectangle(water.left, water.top, water.right - water.left, water.bottom - water.top, 0x2a6fdb)
        .setOrigin(0, 0);
    }
    for (const bridge of BRIDGES) {
      this.add
        .rectangle(bridge.left, bridge.top, bridge.right - bridge.left, bridge.bottom - bridge.top, 0x8b5a2b)
        .setOrigin(0, 0);
    }
    for (const side of ["top", "bottom"] as const) {
      const tower = TOWERS[side];
      this.add.rectangle(tower.x, tower.y, 80, 80, 0x777777).setStrokeStyle(4, SIDE_COLORS[side]);
    }
  }

  private showSide(side: Side | null): void {
    const text = side ? `You are ${side === "bottom" ? "BLUE (bottom)" : "RED (top)"}. Tap your half to spawn.` : "Match full, spectating.";
    this.statusText.setText(text);
  }

  private applyState(units: UnitSnapshot[]): void {
    const alive = new Set<number>();
    for (const unit of units) {
      alive.add(unit.id);
      const view = this.views.get(unit.id);
      if (view) view.apply(unit);
      else this.views.set(unit.id, new UnitView(this, unit));
    }
    for (const [id, view] of this.views) {
      if (!alive.has(id)) {
        view.destroy();
        this.views.delete(id);
      }
    }
  }
}
