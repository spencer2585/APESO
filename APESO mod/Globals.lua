APESO = APESO or {}
--This file creates all global Variables used by the mod

APESO.name = "APESO"

--Item Type Ids/BaseIds
APESO.GoldIncreaseID = 149994
APESO.MainQuestID = 149996
APESO.UnlimitedWalletID = 149997
APESO.BaseOffset = 150000
APESO.WayshrineOffset = APESO.BaseOffset
APESO.WayshrineZoneOffset = APESO.BaseOffset + 1000
APESO.RegionUnlockBaseID = APESO.BaseOffset + 1100

--recived Items
APESO.GoldIncrease = 0
APESO.ProgressiveMainQuest = 0
APESO.HasUnlimitedWallet = false
APESO.ZoneAccess = {}
APESO.WayshrineAccess = {}

APESO.seed = 0
APESO.currentSeedData = {}

APESO.savedVariables = ZO_SavedVars:NewAccountWide("APESOCheckedLocations",1,nil,APESO.Default)
APESO.seed = 0