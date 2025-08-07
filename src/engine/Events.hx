package engine;



//events should be the only way to change the world object

class PlantSeedEvent implements IWorldEvent { /* ... */ }
class UpgradePlantEvent implements IWorldEvent { /* ... */ }
class RemovePlantEvent implements IWorldEvent { /* ... */ }

class InitiateCombatEvent implements IWorldEvent { /* ... */ }
class ExecuteAttackEvent implements IWorldEvent { /* ... */ }
class EndCombatEvent implements IWorldEvent { /* ... */ }

class DayAdvanceEvent implements IWorldEvent { /* ... */ }

class IncrementResourceEvent implements IWorldEvent { /* ... */ }
class DecrementResourceEvent implements IWorldEvent { /* ... */ }

class GetMaterialEvent implements IWorldEvent { /* ... */ }
class RemoveMaterialEvent implements IWorldEvent { /* ... */ }

class ActivateSkillTreeNodeEvent implements IWorldEvent { /* ... */ }

class CraftWeaponEvent implements IWorldEvent { /* ... */ }
class UpgradeWeaponEvent implements IWorldEvent { /* ... */ }

class SpawnMonsterEvent implements IWorldEvent { /* ... */ }
class RemoveMonsterEvent implements IWorldEvent { /* ... */ }

class InitiateRaidEvent implements IWorldEvent { /* ... */ }
class ExecuteRaidEvent implements IWorldEvent { /* ... */ }
class EndRaidEvent implements IWorldEvent { /* ... */ }

class DayAdvanceEvent implements IWorldEvent { /* ... */ }
class ChangeWeatherEvent implements IWorldEvent { /* ... */ }
class ChangeHeatVarianceEvent implements IWorldEvent { /* ... */ }