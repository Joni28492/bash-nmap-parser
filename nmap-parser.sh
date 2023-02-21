#!/bin/bash

# Este progrmaa parsea los resultados de nmap y construye un documento html


TITULO="Resultados Nmap"
FECHA_ACTUAL="$(date)"
TIMESTAMP="Informe generado el $FECHA_ACTUAL por el usuario $LOGNAME"

test_func(){
    local variable1="Esta variable se encuentra dentro de la funcion"
    return
}

exec_nmap(){
    echo "[INFO] Ejecutando nmap en la red $1, Por Favor Espere unos segundos..."
    sudo nmap -sV $1 > $2
    echo "[OK] Fichero $2  generado correctamente"
    return
}



test_func
echo $variable1


if [ $(find $2 -mmin -30) ]; then
    while true; do
	read -p "Existe $2 con antiguedad menor a 30 minutos. Sobreescribir? [y/n]: "
	case "$REPLY" in
	    y) # Generamos el reporte Raw con nmap
		exec_nmap $1 $2                                                                                                                                            # Dividimos el fichero por lineas vacias
	       echo "[INFO] Dividiendo el fichero salida_namp.raw..."
               csplit salida_nmap.raw '/^$/' {*} > /dev/null    
	       echo "[OK] $2 dividido en los siguientes ficheros: $(ls xx*)"
	       break
	       ;;
	    n) echo "[INFO] Utilizando el fichero $2 existente"
	       break
	       ;;
	    esac
    done
else
    # Generamos el reporte Raw con nmap
    exec_nmap $1 $2
    # Dividimos el fichero por lineas vacias
    echo "[INFO] Dividiendo el fichero $2..."
    csplit $2 '/^$/' {*} > /dev/null
    echo "[OK] $2 dividido en los siguientes ficheros: $(ls xx*)"
fi

echo "[INFO] Generando reporte html..."
# Importamos el fichero que genera el reporte HTML
source html_report.sh
#Generamos el reporte html
generar_html > $3
echo "[OK] Reporte $3 generado correctamente"
