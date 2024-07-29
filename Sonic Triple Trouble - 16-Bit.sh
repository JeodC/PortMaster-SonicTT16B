#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/sonictt16b"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/uinput

if [ $CFW_NAME == "*ArkOS*" ]; then
    export LD_LIBRARY_PATH="$GAMEDIR/libs:$GAMEDIR/libs2:$LD_LIBRARY_PATH"
else
    export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
fi

if [ ! -f "game.droid" ]; then
    source repack.txt
fi

if [ -f "sonictt16b.patch" ]; then
    $controlfolder/xdelta3 -d -s "$GAMEDIR/game.droid" "$GAMEDIR/sonictt16b.patch" "$GAMEDIR/game2.droid"
    rm -rf game.droid
    rm -rf sonictt16b.patch
    mv game2.droid game.droid
fi

echo "Loading, please wait... (might take a while!)" > /dev/tty0
$GPTOKEYB "gmloadernext" -xbox360 &
$ESUDO chmod +x "$GAMEDIR/gmloadernext"

./gmloadernext game.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
