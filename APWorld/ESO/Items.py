from typing import Dict, NamedTuple, Optional

from BaseClasses import Item, ItemClassification

eso_base_id: int = 100000

class ESOItem(Item):
    game: str = "Elder Scrolls Online"

class ESOItemData(NamedTuple):
    category:str
    code: Optional[int] = None
    classification: ItemClassification = ItemClassification.filler
    max_quantity: int = 1
    weight: int = 1

def get_items_by_category(category: str) -> Dict[str, ESOItemData]:
    item_dict: Dict[str, ESOItemData] = {}
    for name, data in item_table.items():
        if data.category == category:
            item_dict.setdefault(name, data)

    return item_dict

item_table: Dict[str, ESOItemData] = {
    "Glenumbria Access":        ESOItemData("Zone Access",  eso_base_id+0, ItemClassification.progression),
    "Betnikh Access":           ESOItemData("Zone Access",  eso_base_id+2, ItemClassification.progression),
    "Stormhaven Access":        ESOItemData("Zone Access",  eso_base_id+3, ItemClassification.progression),
    "Rivenspire Access":        ESOItemData("Zone Access",  eso_base_id+4, ItemClassification.progression),
    "Bangkorai Access":         ESOItemData("Zone Access",  eso_base_id+5, ItemClassification.progression),
    "filler":                   ESOItemData("Filler",       eso_base_id+6),
    "Alik'r Desert Access":     ESOItemData("Zone Access",  eso_base_id+7, ItemClassification.progression),
}