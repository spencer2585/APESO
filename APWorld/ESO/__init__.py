import worlds.LauncherComponents as LauncherComponents
from typing import List
from BaseClasses import Tutorial
from worlds.AutoWorld import WebWorld, World
from worlds.LauncherComponents import Component, SuffixIdentifier, Type, components, launch_subprocess, icon_paths
from .Items import ESOItem, ESOItemData, get_items_by_category, item_table
from .Locations import ESOLocation, location_table
from .Options import ESOOptions
from .Regions import create_regions
from .Rules import set_rules

def run_client(*args):
    print("Running ESO Client")
    from .ESOClient import main  # lazy import
    launch_subprocess(main, name="ESOClient", args=args)


components.append(Component("ESO Client", func=run_client, component_type=Type.CLIENT))

class ESOWeb(WebWorld):
    theme = 'stone'
    tutorials = [Tutorial(
        "Multiworld Setup Guide",
        "A guide to set up ESO for AP",
        "English",
        "eso_en.md",
        "eso/en",
        ["Spencer2585"]
    )]

class ESOWorld(World):
    """
    Elder Scrolls Online is a MMORPG Set in the world of The elder Scrolls. Journey across the reagons of Tamriel while fighting 
    against various enemies
    """
    game = "Elder Scrolls Online"
    options_dataclass = ESOOptions
    options: ESOOptions
    required_client_version = (0, 0, 1)
    web = ESOWeb()

    item_name_to_id = {name: data.code for name, data in item_table.items() if data.code is not None}
    location_name_to_id = {name: data.code for name, data in location_table.items() if data.code is not None}

    def create_items(self):
        item_pool: List[ESOItem] = []
        total_locations = len(self.multiworld.get_unfilled_locations(self.player))
        for name, data in item_table.items():
            quantity = data.max_quantity
            item_pool += [self.create_item(name) for _ in range(0, quantity)]
    
        while len(item_pool) < total_locations:
            item_pool.append(self.create_item(self.get_filler_item_name()))

        self.multiworld.itempool += item_pool

    def get_filler_item_name(self) -> str:
        fillers = get_items_by_category("Filler")
        weights = [data.weight for data in fillers.values()]
        return self.random.choices([filler for filler in fillers.keys()], weights, k=1)[0]

    def set_rules(self):
        set_rules(self, self.player)

    def create_regions(self):
        create_regions(self)

    def create_item(self, name: str) -> ESOItem:
        data = item_table[name]
        return ESOItem(name, data.classification, data.code, self.player)

