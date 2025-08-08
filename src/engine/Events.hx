package engine;

// events should be the only way to change the world object
// This module provides short, stable type names that alias the
// actual implementations in `engine.EventImpl`.

typedef PlantSeedEvent = engine.impl.EventImpl.PlantSeedEvent;
typedef UpgradePlantEvent = engine.impl.EventImpl.UpgradePlantEvent;
typedef RemovePlantEvent = engine.impl.EventImpl.RemovePlantEvent;

typedef InitiateCombatEvent = engine.impl.EventImpl.InitiateCombatEvent;
typedef ExecuteAttackEvent = engine.impl.EventImpl.ExecuteAttackEvent;
typedef EndCombatEvent = engine.impl.EventImpl.EndCombatEvent;

typedef DayAdvanceEvent = engine.impl.EventImpl.DayAdvanceEvent;

typedef IncrementResourceEvent = engine.impl.EventImpl.IncrementResourceEvent;
typedef DecrementResourceEvent = engine.impl.EventImpl.DecrementResourceEvent;

typedef GetMaterialEvent = engine.impl.EventImpl.GetMaterialEvent;
typedef RemoveMaterialEvent = engine.impl.EventImpl.RemoveMaterialEvent;

typedef ActivateSkillTreeNodeEvent = engine.impl.EventImpl.ActivateSkillTreeNodeEvent;

typedef CraftWeaponEvent = engine.impl.EventImpl.CraftWeaponEvent;
typedef UpgradeWeaponEvent = engine.impl.EventImpl.UpgradeWeaponEvent;

typedef SpawnMonsterEvent = engine.impl.EventImpl.SpawnMonsterEvent;
typedef RemoveMonsterEvent = engine.impl.EventImpl.RemoveMonsterEvent;

typedef InitiateRaidEvent = engine.impl.EventImpl.InitiateRaidEvent;
typedef ExecuteRaidEvent = engine.impl.EventImpl.ExecuteRaidEvent;
typedef EndRaidEvent = engine.impl.EventImpl.EndRaidEvent;

typedef ChangeWeatherEvent = engine.impl.EventImpl.ChangeWeatherEvent;
typedef ChangeHeatVarianceEvent = engine.impl.EventImpl.ChangeHeatVarianceEvent;