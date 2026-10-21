export interface UnitStats {
  name: string;
  cost: number;
  maxHp: number;
  speed: number;
  radius: number;
  damage: number;
  range: number;
  attackInterval: number;
  color: number;
}

export const UNIT_TYPES = {
  square: {
    name: "Square",
    cost: 3,
    maxHp: 100,
    speed: 45,
    radius: 16,
    damage: 15,
    range: 8,
    attackInterval: 1.2,
    color: 0xdddddd,
  },
} satisfies Record<string, UnitStats>;

export type UnitType = keyof typeof UNIT_TYPES;

export function isUnitType(value: unknown): value is UnitType {
  return typeof value === "string" && Object.prototype.hasOwnProperty.call(UNIT_TYPES, value);
}

export function getStats(type: UnitType): UnitStats {
  return UNIT_TYPES[type];
}
