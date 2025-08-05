package ram;

class GameRAM {
    public var worldData: WorldData;
    public var trizones: Array<TriZoneData>;
    public var inventory: Array<InventoryData>;
    public var mech: MechData;
    public var currentCombat: CombatData;
}

enum HemisDiei {
    Occidental;
    Oriental;
}

class WorldData {
    public var day: Int;
    public var hemis: HemisDiei;
}

class MechData {
    public var maxHP: Int;
    public var currentHP: Int;
    public var maxSlots: Int;
    public var parts: Array<MechPart>;
}