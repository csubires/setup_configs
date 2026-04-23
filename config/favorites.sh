#!/usr/bin/env bash

FAVDIR="$HOME/.config/rofi/favorites"

if [ -z "$@" ]; then
    if [ -d "$FAVDIR" ] && [ "$(ls -A "$FAVDIR"/*.desktop 2>/dev/null)" ]; then
        for f in "$FAVDIR"/*.desktop; do
            if [ -f "$f" ]; then
                NAME=$(grep -m1 '^Name=' "$f" | cut -d= -f2-)
                ICON=$(grep -m1 '^Icon=' "$f" | cut -d= -f2-)
                if [ -n "$NAME" ]; then
                    echo -e "$NAME\0icon\x1f${ICON:-application-x-executable}"
                fi
            fi
        done
    else
        echo "No favorites yet"
        echo "Add .desktop files to ~/.config/rofi/favorites/"
    fi
else
    SELECTION="$@"
    if [[ "$SELECTION" == "No favorites yet"* ]] || [[ "$SELECTION" == "Add .desktop"* ]]; then
        exit 0
    fi
    for f in "$FAVDIR"/*.desktop; do
        if [ -f "$f" ]; then
            NAME=$(grep -m1 '^Name=' "$f" | cut -d= -f2-)
            if [ "$NAME" = "$SELECTION" ]; then
                EXEC=$(grep -m1 '^Exec=' "$f" | cut -d= -f2-)
                if [[ "$EXEC" == *"flatpak run"* ]]; then
                    FLATPAK_ID=$(echo "$EXEC" | grep -oP '(?<=flatpak run )[^ ]+' | tail -1)
                    if [ -z "$FLATPAK_ID" ]; then
                        FLATPAK_ID=$(echo "$EXEC" | awk '{print $NF}' | grep -E '^[a-z]+\.[a-z]+\.[A-Za-z]+')
                    fi

                    if [ -n "$FLATPAK_ID" ]; then
                        (flatpak run "$FLATPAK_ID" &) > /dev/null 2>&1
                    else
                        CLEAN_EXEC=$(echo "$EXEC" | sed 's/ --file-forwarding//g' | sed 's/ @@[^@]*@@//g' | sed 's/ %[FfUu].*$//g')
                        (eval "$CLEAN_EXEC" &) > /dev/null 2>&1
                    fi
                else
                    CLEAN_EXEC=$(echo "$EXEC" | sed 's/ %[FfUu].*$//g')
                    (eval "$CLEAN_EXEC" &) > /dev/null 2>&1
                fi
                if command -v wmctrl &> /dev/null; then
                    sleep 0.5
                    wmctrl -a "$NAME" 2>/dev/null
                fi
                exit 0
            fi
        fi
    done
fi

exit 0
