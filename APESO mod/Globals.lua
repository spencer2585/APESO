APESO = APESO or {}
--This file creates all global Variables used by the mod

APESO.name = "APESO"

--Item Type Ids/BaseIds
APESO.GoldIncreaseID = 149994
APESO.MainQuestID = 149996
APESO.InfiniteWalletID = 149997
APESO.BaseOffset = 150000
APESO.WayshrineOffset = APESO.BaseOffset + 10000 --170000 - 179999 Individual Wayshrine Unlocks
APESO.WayshrineZoneOffset = APESO.BaseOffset + 20000 --160000 - 169999 Wayshrine unlocks for zones
APESO.RegionUnlockBaseID = APESO.BaseOffset --150000 - 159999

--recived Items
APESO.GoldIncrease = 0
APESO.ProgressiveMainQuest = 0
APESO.HasInfiniteWallet = false
APESO.ZoneAccess = {}
APESO.WayshrineAccess = {}

APESO.seed = 0
APESO.currentSeedData = {}

APESO.savedVariables = ZO_SavedVars:NewAccountWide("APESOCheckedLocations",1,nil,APESO.Default)
APESO.seed = 0