import { BRIDGES, RIVER, RIVER_CENTER_Y, type Point, type Rect } from "../shared/arena";

export function nextWaypoint(from: Point, radius: number, destination: Point): Point {
  const goingUp = destination.y < from.y;
  const bridge = closestBridge(from.x);
  const bridgeX = (bridge.left + bridge.right) / 2;

  const nearBankY = goingUp ? RIVER.bottom + radius + 1 : RIVER.top - radius - 1;
  const farBankY = goingUp ? RIVER.top - radius - 1 : RIVER.bottom + radius + 1;

  const inRiverBand = from.y > RIVER.top - radius && from.y < RIVER.bottom + radius;
  const onBridge = inRiverBand && from.x >= bridge.left && from.x <= bridge.right;

  if (onBridge) return { x: bridgeX, y: farBankY };

  if (bankOf(from.y) === bankOf(destination.y) && !inRiverBand) return destination;

  if (Math.abs(from.x - bridgeX) > 2) return { x: bridgeX, y: nearBankY };
  return { x: bridgeX, y: farBankY };
}

function bankOf(y: number): "top" | "bottom" {
  return y < RIVER_CENTER_Y ? "top" : "bottom";
}

function closestBridge(x: number): Rect {
  let best = BRIDGES[0];
  for (const bridge of BRIDGES) {
    const center = (bridge.left + bridge.right) / 2;
    if (Math.abs(center - x) < Math.abs((best.left + best.right) / 2 - x)) best = bridge;
  }
  return best;
}
