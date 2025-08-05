package core;

enum NoArg {NoArg;}

typedef GameCommand<T> = T -> Future;

typedef MoveMechCmd = GameCommand<TriZoneLocation>;
typedef DisplayZoneOptionsCmd = GameCommand<TriZoneLocation>;
typedef PlantSeedCmd = GameCommand<{loc: TriZoneLocation, seedType: SeedType}>;
typedef AdvanceDayCmd = GameCommand<NoArg>;
typedef StartCombat = GameCommand<TriZoneLocation>;