import { ARENA, BASES, type Point } from "../shared/arena";
import type { TeamId } from "../shared/teams";

const CENTER: Point = { x: ARENA.width / 2, y: ARENA.height / 2 };

const OWN_COLOR = 0x2266ff;
const OTHER_COLORS = [0xff3333, 0x33cc55, 0xffcc00, 0xaa44ff];

export class Perspective {
  readonly rotation: number;

  constructor(readonly team: TeamId) {
    const { tower } = BASES[team];
    this.rotation = Math.PI / 2 - Math.atan2(tower.y - CENTER.y, tower.x - CENTER.x);
  }

  toScreen(point: Point): Point {
    return rotateAroundCenter(point, this.rotation);
  }

  toWorld(point: Point): Point {
    return rotateAroundCenter(point, -this.rotation);
  }

  colorOf(team: TeamId): number {
    if (team === this.team) return OWN_COLOR;
    return OTHER_COLORS[(team < this.team ? team : team - 1) % OTHER_COLORS.length];
  }
}

function rotateAroundCenter({ x, y }: Point, angle: number): Point {
  const cos = Math.cos(angle);
  const sin = Math.sin(angle);
  const dx = x - CENTER.x;
  const dy = y - CENTER.y;
  return { x: CENTER.x + dx * cos - dy * sin, y: CENTER.y + dx * sin + dy * cos };
}
