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

# grep -E -h '^[0-9]{1,5}/(tcp|udp) +open' xx* | grep -E -o '^[0-9]{1,5}/(tcp|udp)'

result_parser () {                                                                                                                                 
        for i in xx*; do 
            host_ip=$(grep -E 'Nmap scan report ' $i | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')                                         
            if [ $host_ip ];then                                                                                                                            
               echo "<tr>"                                                                                                                                  
               echo "<td>$host_ip</td>"
               # Obtenemos los puertos abiertos
	       puertos_abiertos=$(grep -E -h '^[0-9]{1,5}/(tcp|udp) +open' $i | grep -E -o '^[0-9]{1,5}/(tcp|udp)')
	       if [ "$puertos_abiertos" ]; then
		   echo "<td>$puertos_abiertos</td>"
	       else
		   echo "<td>No hay puertos abiertos</td>"
               fi                                                                                                  
	       # TODO servicios grep -E  '^[0-9]{1,5}/(tcp|udp) +open +[a-zA-Z0-9]+[[:punct:]]*[a-zA-Z0-9]+ ' xx01 esta incompleta
	       # Obtenemos los servicios
	       servicios=$(grep -E -h '^[0-9]{1,5}/(tcp|udp) +open' $i | grep -E -o ' .* ')
	       if [ "$servicios" ]; then
		   echo "<td>$servicios</td>"
	       else
		   echo "<td>No hay servicios expuestos</td>"
	       fi                                                                                                                         
               echo "</tr>"                                                                                                                                 
            fi                                                                                                                                              
        done
	return 0
}


generar_html(){
    cat <<EOF

    <html>
	<head>
		<title>$TITULO</title>
    	</head>
       <style>
	table {
	 font-family: arial, sans-serif;
       	 border-collapse: collapse;
      	 width: 100%;
       	}

	td, th {
  	 border: 1px solid #dddddd;
  	 text-align: left;
  	 padding: 8px;
	}

	tr:nth-child(even) {
  	 background-color: #dddddd;
	}
       </style>
    	<body>
		<h1>$TITULO</h1>
		<p1>$TIMESTAMP</p1>
	<table>
  	<tr>
		<th>Host IP</th>
    		<th>Puertos abiertos</th>
    		<th>Servicio</th>
  	</tr>

	$(result_parser) 
      	</table>

    	</body>
	</html>
EOF
}


test_func
echo $variable1


if [ $(find salida_nmap.raw -mmin -30) ]; then
    while true; do
	read -p "Existe salida_nmap.raw con antiguedad menor a 30 minutos. Sobreescribir? [y/n]: "
	case "$REPLY" in
	    y) # Generamos el reporte Raw con nmap
	       exec_nmap "192.168.1.0/24" "salida_nmap.raw"                                                                                                                # Dividimos el fichero por lineas vacias
	       echo "[INFO] Dividiendo el fichero salida_namp.raw..."
               csplit salida_nmap.raw '/^$/' {*} > /dev/null    
	       echo "[OK] salida_namp.raw dividido en los siguientes ficheros: $(ls xx*)"
	       break
	       ;;
	    n) echo "[INFO] Utilizando el fichero salida_nmap.raw existente"
	       break
	       ;;
	    esac
    done
else
    # Generamos el reporte Raw con nmap
    exec_nmap "192.168.1.0/24" "salida_nmap.raw"
    # Dividimos el fichero por lineas vacias
    echo "[INFO] Dividiendo el fichero salida_namp.raw..."
    csplit salida_nmap.raw '/^$/' {*} > /dev/null
    echo "[OK] salida_namp.raw dividido en los siguientes ficheros: $(ls xx*)"
fi

# Generamos el reporte con los resultados de nmap en HTML
echo "[INFO] Generando reporte HTML"
generar_html > resultados_nmap.html
echo "[OK] Reporte resultados_nmap.html"
