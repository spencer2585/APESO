import asyncio
import os
import time
import traceback

from schema import Optional

import NetUtils
import Utils
from typing import Any

from CommonClient import get_base_parser, gui_enabled, logger, server_loop, ClientCommandProcessor, CommonContext
from settings import get_settings, Settings

CLIENT_VERSION = "0.0.1"

class ESOClientCommandProcessor(ClientCommandProcessor):
    def __init__(self, ctx: CommonContext):
        super().__init__(ctx)


class ESOContext(CommonContext):
    command_processor: int = ESOClientCommandProcessor
    game = "Elder Scrolls Online"

    def __init__(self, server_address, password):
        super().__init__(server_address, password)

    def _cmd_test(self):
        logger.info(f"test")

def main(connect=None, password=None):
    Utils.init_logging("Elder Scrolls Online Client")

    async def _main(connect, password):
        ctx = ESOContext(connect, password)
        ctx.server_task = asyncio.create_task(server_loop(ctx), name="ServerLoop")

        if gui_enabled:
            ctx.run_gui()
        ctx.run_cli()
        await asyncio.sleep(1)

        await ctx.exit_event.wait()
        await ctx.shutdown()

    import colorama

    colorama.just_fix_windows_console()
    asyncio.run(_main(connect, password))
    colorama.deinit()

if __name__ == "__main__":
    parser = get_base_parser()
    args = parser.parse_args()
    main(args.connect, args.password)