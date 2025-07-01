from typing import Dict, NamedTuple, Optional

from BaseClasses import Location

class ESOLocation(Location):
    game: str = "Elder Scrolls Online"


class ESOLocationData(NamedTuple):
    category: str
    code: Optional[int] = None

def get_locations_by_category(category: str) -> Dict[str, ESOLocationData]:
    location_dict: Dict[str, ESOLocationData] = {}
    for name, data in location_table.items():
        if data.category == category:
            location_dict.setdefault(name, data)

    return location_dict


location_table: dict[str, ESOLocationData] = {
    "Glenumbria - Daggerfall Wayshrine":        ESOLocationData("Glenumbria",   150_000),
    "Glenumbria - Baelborne Rock Wayshrine":    ESOLocationData("Glenumbria",   150_001),
    "Glenumbria - Deleyn's Mill Wayshrine":     ESOLocationData("Glenumbria",   150_002),
    "Glenumbria - Wyrd Tree Wayshrine":         ESOLocationData("Glenumbria",   150_003),
    "Glenumbria - Farwatch Wayshrine":          ESOLocationData("Glenumbria",   150_004),
    "Glenumbria - Aldcroft Wayshrine":          ESOLocationData("Glenumbria",   150_005),
    "Glenumbria - Eagle's Brook Wayshrine":     ESOLocationData("Glenumbria",   150_006),
    "Glenumbria - Hag Fen Wayshrine":           ESOLocationData("Glenumbria",   150_007),
    "Glenumbria - North Hag Fen Wayshrine":     ESOLocationData("Glenumbria",   150_008),
    "Glenumbria - Lion Guard Redoubt Wayshrine":ESOLocationData("Glenumbria",   150_009),
    "Glenumbria - Crosswych Wayshrine":         ESOLocationData("Glenumbria",   150_010),
    "Stros M'kai - Port Hunding Wayshrine":     ESOLocationData("Stros M'kai",  150_011),
    "Stros M'kai - Saintsport Wayshrine":       ESOLocationData("Stros M'kai",  150_012),
    "Stros M'kai - Sandy Grotto Wayshrine":     ESOLocationData("Stros M'kai",  150_013),
    "Betnikh - Stonetooth Wayshrine":           ESOLocationData("Betnikh",      150_014),
    "Betnikh - Carved Hills Wayshrine":         ESOLocationData("Betnikh",      150_015),
    "Betnikh - Grimfield Wayshrine":            ESOLocationData("Betnikh",      150_016),
    "Rivenspire - Camp Tamrith Wayshrine":      ESOLocationData("Rivenspire",   150_017),
    "Rivenspire - Oldgate Wayshrine":           ESOLocationData("Rivenspire",   150_018),
    "Rivenspire - Sanguine Barrows Wayshrine":  ESOLocationData("Rivenspire",   150_019),
    "Rivenspire - Hoarfrost Downs Wayshrine":   ESOLocationData("Rivenspire",   150_020),
    "Rivenspire - Shornhelm Wayshrine":         ESOLocationData("Rivenspire",   150_021),
    "Rivenspire - Crestshade Wayshrine":        ESOLocationData("Rivenspire",   150_022),
    "Rivenspire - Shrouded Pass Wayshrine":     ESOLocationData("Rivenspire",   150_023),
    "Rivenspire - Fell's Run Wayshrine":        ESOLocationData("Rivenspire",   150_024),
    "Rivenspire - Staging Grounds Wayshrine":   ESOLocationData("Rivenspire",   150_025),
    "Rivenspire - Boralis Wayshrine":           ESOLocationData("Rivenspire",   150_026),
    "Rivenspire - Northpoint Wayshrine":        ESOLocationData("Rivenspire",   150_027),
    "Stormhaven - Alcaire Castle Wayshrine":    ESOLocationData("Stormhaven",   150_028),
    "Stormhaven - Koeglin Village Wayshrine":   ESOLocationData("Stormhaven",   150_029),
    "Stormhaven - Firebrand Wayshrine":         ESOLocationData("Stormhaven",   150_030),
    "Stormhaven - Bonesnap Ruins Wayshrine":    ESOLocationData("Stormhaven",   150_031),
    "Stormhaven - Soulshriven Wayshrine":       ESOLocationData("Stormhaven",   150_032),
    "Stormhaven - Pariah Abbey Wayshrine":      ESOLocationData("Stormhaven",   150_033),
    "Stormhaven - Wayrest Wayshrine":           ESOLocationData("Stormhaven",   150_034),
    "Stormhaven - Dro'dara Plantation Wayshrine":ESOLocationData("Stormhaven",  150_035),
    "Stormhaven - Wind Keep Wayshrine":         ESOLocationData("Stormhaven",   150_036),
    "Stormhaven - Weeping Giant Wayshrine":     ESOLocationData("Stormhaven",   150_037),
    "Bangkorai - Halcyon Lake Wayshrine":       ESOLocationData("Bangkorai",    150_038),
    "Bangkorai - Troll's Toothpick Wayshrine":  ESOLocationData("Bangkorai",    150_039),
    "Bangkorai - Evermore Wayshrine":           ESOLocationData("Bangkorai",    150_040),
    "Bangkorai - Eastern Evermore Wayshrine":   ESOLocationData("Bangkorai",    150_041),
    "Bangkorai - Viridian Woods Wayshrine":     ESOLocationData("Bangkorai",    150_042),
    "Bangkorai - Bangkorai Pass Wayshrine":     ESOLocationData("Bangkorai",    150_043),
    "Bangkorai - Sunken Road Wayshrine":        ESOLocationData("Bangkorai",    150_044),
    "Bangkorai - Nalata Ruins Wayshrine":       ESOLocationData("Bangkorai",    150_045),
    "Bangkorai - Hallin's Stand Wayshrine":     ESOLocationData("Bangkorai",    150_046),
    "Bangkorai - Onsi's Breath Wayshrine":      ESOLocationData("Bangkorai",    150_047),
    "Bangkorai - Old Tower Wayshrine":          ESOLocationData("Bangkorai",    150_048),
    "Alik'r - Satakalaam Wayshrine":            ESOLocationData("Alik'r Desert",150_049),
    "Alik'r - Shrikes' Aerie Wayshrine":        ESOLocationData("Alik'r Desert",150_050),
    "Alik'r - HoonDing's Watch Wayshrine":      ESOLocationData("Alik'r Desert",150_051),
    "Alik'r - Sep's Spine Wayshrine":           ESOLocationData("Alik'r Desert",150_052),
    "Alik'r - Leki's Blade Wayshrine":          ESOLocationData("Alik'r Desert",150_053),
    "Alik'r - Aswala Stables Wayshrine":        ESOLocationData("Alik'r Desert",150_054),
    "Alik'r - Kulati Mines Wayshrine":          ESOLocationData("Alik'r Desert",150_055),
    "Alik'r - Bergama Wayshrine":               ESOLocationData("Alik'r Desert",150_056),
    "Alik'r - Goat's Head Oasis Wayshrine":     ESOLocationData("Alik'r Desert",150_057),
    "Alik'r - Divad's Chagrin Mine Wayshrine":  ESOLocationData("Alik'r Desert",150_058),
    "Alik'r - Morwha's Bounty Wayshrine":       ESOLocationData("Alik'r Desert",150_059),
    "Alik'r - Sentinel Wayshrine":              ESOLocationData("Alik'r Desert",150_060),
}