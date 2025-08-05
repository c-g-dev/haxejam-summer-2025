package inventory;

enum InventoryItemType {
    Resource;
    Precious;
    Seed;
}

class InventoryItem {
    var type: InventoryItemType;
}

enum ResourceType {
    Sunlight;
    Nitrogen;
    Phosphor;
    Potassium;
}