import express from "express";
import { createServer } from "node:http";
import path from "node:path";
import { Server } from "socket.io";
import { TICK_RATE } from "../shared/arena";
import type { ClientToServerEvents, ServerToClientEvents } from "../shared/protocol";
import { MODES } from "../shared/teams";
import { isUnitType } from "../shared/units";
import { Match } from "./Match";
import { Roster } from "./Roster";

const PORT = Number(process.env.PORT ?? 3000);
const isProduction = process.env.NODE_ENV === "production";

const app = express();
const httpServer = createServer(app);
const io = new Server<ClientToServerEvents, ServerToClientEvents>(httpServer, {
  destroyUpgrade: false,
});

const match = new Match();

const roster = new Roster(MODES["1v1"]);

io.on("connection", (socket) => {
  const seat = roster.join(socket.id);
  socket.emit("welcome", { seat });

  socket.on("spawn", (request) => {
    if (!seat || !request || !isUnitType(request.type)) return;
    if (!Number.isFinite(request.x) || !Number.isFinite(request.y)) return;
    match.spawn(request.type, seat.team, request.x, request.y);
  });

  socket.on("disconnect", () => {
    roster.leave(socket.id);
    if (roster.isEmpty) match.clear();
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
