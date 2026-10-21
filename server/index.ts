import express from "express";
import { createServer } from "node:http";
import path from "node:path";
import { Server } from "socket.io";
import { TICK_RATE, type Side } from "../shared/arena";
import type { ClientToServerEvents, ServerToClientEvents } from "../shared/protocol";
import { isUnitType } from "../shared/units";
import { Match } from "./Match";

const PORT = Number(process.env.PORT ?? 3000);
const isProduction = process.env.NODE_ENV === "production";

const app = express();
const httpServer = createServer(app);
const io = new Server<ClientToServerEvents, ServerToClientEvents>(httpServer, {
  destroyUpgrade: false,
});

const match = new Match();

const players: Record<Side, string | null> = { top: null, bottom: null };

function claimSide(socketId: string): Side | null {
  for (const side of ["bottom", "top"] as const) {
    if (players[side] === null) {
      players[side] = socketId;
      return side;
    }
  }
  return null;
}

io.on("connection", (socket) => {
  const side = claimSide(socket.id);
  socket.emit("welcome", { side });

  socket.on("spawn", (request) => {
    if (!side || !request || !isUnitType(request.type)) return;
    if (!Number.isFinite(request.x) || !Number.isFinite(request.y)) return;
    match.spawn(request.type, side, request.x, request.y);
  });

  socket.on("disconnect", () => {
    if (side) players[side] = null;
    if (!players.top && !players.bottom) match.clear();
  });
});

setInterval(() => {
  match.tick(1 / TICK_RATE);
  io.emit("state", match.snapshot());
}, 1000 / TICK_RATE);

if (isProduction) {
  app.use(express.static(path.resolve(import.meta.dirname, "../dist")));
} else {
  const { createServer: createViteServer } = await import("vite");
  const vite = await createViteServer({
    configFile: "vite/config.dev.mjs",
    server: { middlewareMode: true, hmr: { server: httpServer } },
    appType: "spa",
  });
  app.use(vite.middlewares);
}

httpServer.listen(PORT, () => {
  console.log(`${isProduction ? "Stable" : "Dev"} server running on http://localhost:${PORT}`);
});
