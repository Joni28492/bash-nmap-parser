#!/bin/bash

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
