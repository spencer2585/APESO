from BaseClasses import CollectionState
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from . import ESOWorld

def set_rules(world: "ESOWorld", player: int):
    world.get_entrance("Betnikh - Glenumbria").access_rule = \
        lambda state: state.has("Glenumbria Access",player,1)
    world.get_entrance("Stros M'kai - Betnikh").access_rule = \
        lambda state: state.has("Betnikh Access",player,1)
    world.get_entrance("Stormhaven - Rivenspire").access_rule = \
        lambda state: state.has("Rivenspire Access",player,1)
    world.get_entrance("Glenumbria - Stormhaven").access_rule = \
        lambda state: state.has("Stormhaven Access",player,1)
    world.get_entrance("Rivenspire - Bangkorai").access_rule = \
        lambda state: state.has("Bangkorai Access",player,1)
    world.get_entrance("Stormhaven - Alik'r Desert").access_rule = \
        lambda state: state.has("Alik'r Desert Access", player, 1)