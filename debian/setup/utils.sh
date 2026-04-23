#!/usr/bin/env bash

#Colours
declare -A PALETTE
PALETTE[w]="\e[97m"
PALETTE[r]="\e[91m"
PALETTE[g]="\e[92m"
PALETTE[y]="\e[93m"
PALETTE[b]="\e[94m"
PALETTE[v]="\e[95m"
PALETTE[c]="\e[96m"
PALETTE[o]="\e[33m"
PALETTE[n]="\e[1m"
PALETTE[u]="\e[04m"
PALETTE[t]="\t\e[1;42;97m"

# w: Blanco
# r: Rojo
# g: Verde
# b: Azul
# y: Amarillo
# v: Violeta
# c: Cian
# o: Naranaja
# n: Negrita
# u: Delineado
# t: Título

# Colorear cada mensaje pasado por parametro
function lg_prt() {
	# Como mínimo tiene que tener 3 argumentos. namescript, colors, mensajes
	if [[ ! "$2" ]]; then
		echo -e "${PALETTE[r]} Error (lg_prt), Número de argumentos insuficientes\033[0m\e[0m"
		return 1
	fi

	# Controlar que el número de colores sea igual que el de mensajes
	colors=$(printf "$1%${#@}s\n" | tr ' ' 'b')

	# Colorear cada mensaje quitando los 2 primeros argumentos
	i=0
	for arg in "${@:2}"; do
    	echo -ne "${PALETTE[${colors:$i:1}]} $arg \033[0m\e[0m"
    	i=$[$i+1]
	done
	echo
}

function testColors() {
	for color in "${!PALETTE[@]}"; do
		lg_prt "${color}" "Color: ${color}"
	done
}
