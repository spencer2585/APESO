from typing import Dict, List, NamedTuple, Optional, TYPE_CHECKING

from BaseClasses import MultiWorld, Region, Entrance
from .Locations import ESOLocation, location_table, get_locations_by_category

if TYPE_CHECKING:
    from . import ESOWorld

class ESORegionData(NamedTuple):
    locations: Optional[List[str]]

def create_regions(world: "ESOWorld"):
    regions: Dict[str,  ESORegionData] = {
        "Menu":         ESORegionData([]),
        "Glenumbria":   ESORegionData([]),
        "Stros M'kai":  ESORegionData([]),
        "Betnikh":      ESORegionData([]),
        "Stormhaven":   ESORegionData([]),
        "Rivenspire":   ESORegionData([]),
        "Bangkorai":    ESORegionData([]),
        "Alik'r Desert":ESORegionData([]),
    }

    for glenubria in get_locations_by_category("Glenumbria").keys():
        regions["Glenumbria"].locations.append(glenubria)
    for strosMkai in get_locations_by_category("Stros M'kai").keys():
        regions["Stros M'kai"].locations.append(strosMkai)
    for betnikh in get_locations_by_category("Betnikh").keys():
        regions["Betnikh"].locations.append(betnikh)
    for stormhaven in get_locations_by_category("Stormhaven").keys():
        regions["Stormhaven"].locations.append(stormhaven)
    for rivenspire in get_locations_by_category("Rivenspire").keys():
        regions["Rivenspire"].locations.append(rivenspire)
    for bangkorai in get_locations_by_category("Bangkorai").keys():
        regions["Bangkorai"].locations.append(bangkorai)
    for alikr in get_locations_by_category("Alik'r Desert").keys():
        regions["Alik'r Desert"].locations.append(alikr)



    for name, data in regions.items():
        world.multiworld.regions.append(create_region(world.multiworld, world.player, name, data))
    world.get_region("Menu").exits.append(Entrance(world.player,"Menu - Stros M'kai", world.get_region("Menu")))
    world.get_entrance("Menu - Stros M'kai").connect(world.get_region("Stros M'kai"))
    world.get_region("Stros M'kai").exits.append(Entrance(world.player, "Stros M'kai - Betnikh", world.get_region("Stros M'kai")))
    world.get_entrance("Stros M'kai - Betnikh").connect(world.get_region("Betnikh"))
    world.get_region("Betnikh").exits.append(Entrance(world.player, "Betnikh - Glenumbria", world.get_region("Betnikh")))
    world.get_entrance("Betnikh - Glenumbria").connect(world.get_region("Glenumbria"))
    world.get_region("Glenumbria").exits.append(Entrance(world.player, "Glenumbria - Stormhaven", world.get_region("Glenumbria")))
    world.get_entrance("Glenumbria - Stormhaven").connect(world.get_region("Stormhaven"))
    world.get_region("Stormhaven").exits.append(Entrance(world.player, "Stormhaven - Rivenspire", world.get_region("Stormhaven")))
    world.get_entrance("Stormhaven - Rivenspire").connect(world.get_region("Rivenspire"))
    world.get_region("Rivenspire").exits.append(Entrance(world.player, "Rivenspire - Bangkorai", world.get_region("Rivenspire")))
    world.get_entrance("Rivenspire - Bangkorai").connect(world.get_region("Bangkorai"))
    world.get_region("Stormhaven").exits.append(Entrance(world.player, "Stormhaven - Alik'r Desert", world.get_region("Stormhaven")))
    world.get_entrance("Stormhaven - Alik'r Desert").connect(world.get_region("Stormhaven"))

def create_region(multiworld: MultiWorld, player: int, name: str, data: ESORegionData):
    region = Region(name, player, multiworld)
    if data.locations:
        for loc_name in data.locations:
            loc_data = location_table.get(loc_name)
            location = ESOLocation(player, loc_name, loc_data.code if loc_data else None, region)
            region.locations.append(location)
    return region
