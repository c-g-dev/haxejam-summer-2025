package grid;

typedef VariantResource = {base: Int, varianceLow: Int, varianceHigh: Int}

typedef ZoneInfo = {
    temp: VariantResource,
    wetness: VariantResource,
    climate: Array<ClimateKind>,
    soilType: SoilType,
    preciousMaterials: Array<PreciousMaterialDrop>,
    baseMonster: Monster,
    monsterSpawns: Array<MonsterSpawn>
}

class TriData {
    public var idx: Int;
    public var adjacent: Array<Int>;
    public var plant: PlantOnGrid;
    public var info: ZoneInfo;
}