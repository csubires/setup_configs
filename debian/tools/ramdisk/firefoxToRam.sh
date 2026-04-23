#!/usr/bin/env bash

sudo cp -a ~/.mozilla/firefox/tijioauo.default/ /var/ramdisk/ramdrive/profiles

Crear perfil desde el profio firefox about:profiles

y cambiar en el archivo /home/user/.mozilla/firefox/profiles.ini  Profile2

[Profile2]
Name=mio
IsRelative=0
Path=/var/ramdisk/ramdrive/profiles/tijioauo.default
Default=1
