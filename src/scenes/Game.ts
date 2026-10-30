import { Scene, type GameObjects, type Input } from "phaser";
import { io, type Socket } from "socket.io-client";
import { BASES, BRIDGES, RIVER_SEGMENTS, type Rect } from "../../shared/arena";
import type { ClientToServerEvents, ServerToClientEvents, UnitSnapshot } from "../../shared/protocol";
import type { Seat } from "../../shared/teams";
import type { UnitType } from "../../shared/units";
import { Perspective } from "../Perspective";
import { UnitView } from "../UnitView";

export class Game extends Scene {
  private socket!: Socket<ServerToClientEvents, ClientToServerEvents>;
  private views = new Map<number, UnitView>();
  private perspective?: Perspective;
  private arena?: GameObjects.Container;
  // private statusText!: GameObjects.Text;
  private selectedType: UnitType = "gobler";

  constructor() {
    super({ key: "Game" });
  }

  preload(): void {
    this.load.image("gobler", "assets/gobler.png")
  }

  create(): void {
    // this.add.text(10, 10, "Connecting...", { fontSize: "20px", color: "#ffffff" }).setDepth(10);

    this.socket = io();
    this.socket.on("welcome", ({ seat }) => this.takeSeat(seat));
    this.socket.on("state", (units) => this.applyState(units));
    this.events.once("shutdown", () => this.socket.disconnect());

    this.input.on("pointerdown", (pointer: Input.Pointer) => {
      if (!this.perspective) return;
      const { x, y } = this.perspective.toWorld({ x: pointer.worldX, y: pointer.worldY });
      this.socket.emit("spawn", { type: this.selectedType, x, y });
    });
  }

  update(_time: number, deltaMs: number): void {
    for (const view of this.views.values()) view.update(deltaMs);
  }

  private takeSeat(seat: Seat | null): void {
    this.perspective = new Perspective(seat?.team ?? 0);
    for (const view of this.views.values()) view.destroy();
    this.views.clear();
    this.arena?.destroy();
    this.arena = this.drawArena(this.perspective);
  }

  private drawArena(perspective: Perspective): GameObjects.Container {
    const arena = this.add.container();
    for (const water of RIVER_SEGMENTS) arena.add(this.drawRect(perspective, water, 0x2a6fdb));
    for (const bridge of BRIDGES) arena.add(this.drawRect(perspective, bridge, 0x8b5a2b));
    BASES.forEach(({ tower }, team) => {
      const { x, y } = perspective.toScreen(tower);
      arena.add(
        this.add
          .rectangle(x, y, 80, 80, 0x777777)
          .setRotation(perspective.rotation)
          .setStrokeStyle(4, perspective.colorOf(team)),
      );
    });
    return arena;
  }

  private drawRect(perspective: Perspective, rect: Rect, color: number): GameObjects.Rectangle {
    const center = perspective.toScreen({ x: (rect.left + rect.right) / 2, y: (rect.top + rect.bottom) / 2 });
    return this.add
      .rectangle(center.x, center.y, rect.right - rect.left, rect.bottom - rect.top, color)
      .setRotation(perspective.rotation);
  }

  // private showSide(side: Side | null): void {
  //   const text = side ? `You are ${side === "bottom" ? "BLUE (bottom)" : "RED (top)"}. Tap your half to spawn.` : "Match full, spectating.";
  //   this.statusText.setText(text);
  // }

  private applyState(units: UnitSnapshot[]): void {
    if (!this.perspective) return;
    const alive = new Set<number>();
    for (const unit of units) {
      alive.add(unit.id);
      const view = this.views.get(unit.id);
      if (view) view.apply(unit);
      else this.views.set(unit.id, new UnitView(this, unit, this.perspective));
    }
    for (const [id, view] of this.views) {
      if (!alive.has(id)) {
        view.destroy();
        this.views.delete(id);
      }
    }
  }
}
