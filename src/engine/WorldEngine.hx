package engine;

enum WorldEventType {
    PlantPlanted;
    PlantRemoved;
    MonsterSpawned;
    MonsterRemoved;
    DayTick;
    ...
}

typedef WorldEvent = {type: WorldEventType, future: Future}

class WorldEngine {
    var queue: Array<WorldEvent> = [];
}