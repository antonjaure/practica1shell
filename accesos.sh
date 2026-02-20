#!/bin/bash

# 1. Comprobar que se pasan exactamente dos parámetros
if [ "$#" -ne 2 ]; then
    echo "Error: Número de parámetros incorrecto."
    echo "Uso: $0 [-c | GET/POST | -s | -t | -o | IP] ruta/access.log"
    exit 1
fi

OPCION="$1"
ARCHIVO="$2"

# 2. Comprobar que el segundo parámetro es un archivo regular y tiene permisos de lectura
if [ ! -f "$ARCHIVO" ] || [ ! -r "$ARCHIVO" ]; then
    echo "Error: El archivo '$ARCHIVO' no existe, no es un archivo regular o no tiene permisos de lectura."
    echo "Uso: $0 [-c | GET/POST | -s | -t | -o | IP] ruta/access.log"
    exit 1
fi

case "$OPCION" in
    -c)
        # Códigos de respuesta únicos y su conteo
        awk '{print $9}' "$ARCHIVO" | sort | uniq -c | awk '{printf "Código %s: %s veces\n", $2, $1}'
        ;;

    -t)
        # Días sin acceso en el rango fecha inicio - fecha fin
        fechas=$(awk '{print $4}' "$ARCHIVO" | cut -d'[' -f2 | cut -d':' -f1 | sort -u)
        min_epoch=20000000000
        max_epoch=0
        dias_con_acceso=0
        
        export LC_TIME=en_US.UTF-8
        for f in $fechas; do
            f_espacios="${f//\// }"
            epoch=$(date -d "$f_espacios" +%s 2>/dev/null)
            if [ -n "$epoch" ]; then
                ((dias_con_acceso++))
                [[ $epoch -lt $min_epoch ]] && min_epoch=$epoch
                [[ $epoch -gt $max_epoch ]] && max_epoch=$epoch
            fi
        done
        
        if [ "$dias_con_acceso" -gt 0 ]; then
            dias_totales=$(( (max_epoch - min_epoch) / 86400 + 1 ))
            echo "$((dias_totales - dias_con_acceso))"
        fi
        ;;

    GET|POST)
        # Accesos tipo GET/POST con respuesta 200
        cantidad=$(awk -v m="\"$OPCION" '$6 == m && $9 == "200" {c++} END {print c+0}' "$ARCHIVO")
        fecha_exec=$(LANG=en_US.UTF-8 date "+%b %d %H:%M:%S")
        echo "${fecha_exec}. Registrados ${cantidad} accesos tipo $OPCION con respuesta 200."
        ;;

    -s)
        # KiB enviados por mes
        awk '{
            split($4, p, "/"); mes = p[2]
            bytes = ($10 == "-") ? 0 : $10
            sum[mes] += bytes; acc[mes]++
        } END {
            for (m in sum) printf "%d KiB sent in %s by %d accesses.\n", int(sum[m]/1024), m, acc[m]
        }' "$ARCHIVO"
        ;;

    -o)
        # Ordenar por IP y Bytes (decreciente)
        sort -t ' ' -k1,1 -k10,10nr "$ARCHIVO" > access_ord.log
        echo "Resultado guardado en access_ord.log"
        ;;

    *)
        # 1. Filtramos por la IP indicada ($OPCION) en la primera columna
        # 2. Por cada coincidencia, extraemos y mostramos los datos individuales
        awk -v ip="$OPCION" '
        $1 == ip {
            # Extraemos la fecha y la hora del campo 4
            # El formato original es [10/Oct/2000:13:55:36
            split($4, p, ":")
            fecha = substr(p[1], 2)   # Quita el "[" inicial
            
            # Obtenemos la hora, minutos y segundos uniendo el resto de p
            hora = p[2] ":" p[3] ":" p[4]
            
            # El campo 10 son los bytes; si es "-", lo tratamos como 0
            bytes = ($10 == "-") ? 0 : $10
            
            # Imprimimos cada acceso de forma independiente
            # Formato: Fecha Hora Bytes
            printf "Fecha: %s | Hora: %s | Bytes enviados: %s\n", fecha, hora, bytes
        }' "$ARCHIVO"
        ;;
esac