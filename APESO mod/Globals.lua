APESO = APESO or {}
--This file creates all global Variables used by the mod

APESO.name = "APESO"

--Item Type Ids/BaseIds
APESO.GoldIncreaseID = 149994
APESO.MainQuestID = 149996
APESO.RegionUnlockBaseID = 150000

--recived Items
APESO.GoldIncrease = 0
APESO.ProgressiveMainQuest = 0
APESO.ZoneAccess = {}

APESO.seed = 0
APESO.currentSeedData = {}

APESO.savedVariables = ZO_SavedVars:NewAccountWide("APESOCheckedLocations",1,nil,APESO.Default)
APESO.seed = 0