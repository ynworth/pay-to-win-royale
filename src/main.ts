import { AUTO, Scale, Game as PhaserGame } from "phaser";
import { ARENA } from "../shared/arena";
import { Game } from "./scenes/Game";

const config: Phaser.Types.Core.GameConfig = {
  type: AUTO,
  backgroundColor: "#3a7d44",
  scene: [Game],
  scale: {
    mode: Scale.FIT,
    width: ARENA.width,
    height: ARENA.height,
    parent: "game-container",
  },
};

document.addEventListener("DOMContentLoaded", () => {
  new PhaserGame(config);
});
