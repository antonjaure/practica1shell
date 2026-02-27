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
        # Extraemos la columna 9 con cut (código de estado), ordenamos y contamos
        cut -d' ' -f9 "$ARCHIVO" | sort | uniq -c | while read count code; do
            echo "Código $code: $count veces"
        done
        ;;

    -t)
        # Días sin acceso en el rango fecha inicio - fecha fin
        # Extraemos la fecha (ej: 10/Oct/2000), eliminamos corchetes y sacamos valores únicos
        fechas=$(cut -d' ' -f4 "$ARCHIVO" | cut -d'[' -f2 | cut -d':' -f1 | sort -u)
        min_epoch=20000000000
        max_epoch=0
        dias_con_acceso=0
        
        export LC_TIME=en_US.UTF-8
        for f in $fechas; do
            # Reemplazamos las '/' por espacios para que date lo entienda (ej: "10 Oct 2000")
            f_espacios="${f//\// }"
            epoch=$(date -d "$f_espacios" +%s 2>/dev/null)
            if [ -n "$epoch" ]; then
                ((dias_con_acceso++))
                [ "$epoch" -lt "$min_epoch" ] && min_epoch=$epoch
                [ "$epoch" -gt "$max_epoch" ] && max_epoch=$epoch
            fi
        done
        
        if [ "$dias_con_acceso" -gt 0 ]; then
            # Calculamos los días totales dividiendo los segundos entre 86400 (segundos por día)
            dias_totales=$(( (max_epoch - min_epoch) / 86400 + 1 ))
            echo $((dias_totales - dias_con_acceso))
        else
            echo "0"
        fi
        ;;

    GET|POST)
        # Accesos tipo GET/POST con respuesta 200
        cantidad=0
        while read -r ip guion1 guion2 fecha_hora zona metodo url protocolo codigo bytes resto; do
            # Limpiamos las comillas iniciales del método (ej: "GET -> GET)
            metodo_limpio="${metodo#\"}"
            if [ "$metodo_limpio" = "$OPCION" ] && [ "$codigo" = "200" ]; then
                ((cantidad++))
            fi
        done < "$ARCHIVO"

        fecha_exec=$(LANG=en_US.UTF-8 date "+%b %d %H:%M:%S")
        echo "${fecha_exec}. Registrados ${cantidad} accesos tipo $OPCION con respuesta 200."
        ;;

    -s)
        # KiB enviados por mes
        declare -A sum_mes
        declare -A acc_mes

        while read -r ip guion1 guion2 fecha_hora zona metodo url protocolo codigo bytes resto; do
            # fecha_hora viene como [10/Oct/2000:13:55:36
            fecha_limpia="${fecha_hora#\[}"   # Quitamos el '['
            mes="${fecha_limpia#*/}"          # Quitamos el día y la primera '/'
            mes="${mes%%/*}"                  # Nos quedamos con lo anterior a la segunda '/' (el mes)
            
            [ "$bytes" = "-" ] && bytes=0
            
            ((sum_mes[$mes]+=$bytes))
            ((acc_mes[$mes]++))
        done < "$ARCHIVO"

        for m in "${!sum_mes[@]}"; do
            kib=$(( sum_mes[$m] / 1024 ))
            echo "$kib KiB sent in $m by ${acc_mes[$m]} accesses."
        done
        ;;

    -o)
        # Ordenar por IP y Bytes (decreciente)
        # Asumiendo un log estándar, las IP están en la col 1 y los bytes en la 10
        sort -t ' ' -k1,1 -k10,10nr "$ARCHIVO" > access_ord.log
        echo "Resultado guardado en access_ord.log"
        ;;

    *)
        # 1. Filtramos por la IP indicada ($OPCION)
        # 2. Mostramos total de accesos por DÍA y total de bytes ese día (como pedía el enunciado)
        declare -A accesos_dia
        declare -A bytes_dia

        while read -r ip guion1 guion2 fecha_hora zona metodo url protocolo codigo bytes resto; do
            if [ "$ip" = "$OPCION" ]; then
                # Extraemos el día completo en formato DD/Mon/YYYY
                fecha_limpia="${fecha_hora#\[}"
                dia="${fecha_limpia%%:*}" 
                
                [ "$bytes" = "-" ] && bytes=0
                
                ((accesos_dia[$dia]++))
                ((bytes_dia[$dia]+=$bytes))
            fi
        done < "$ARCHIVO"

        if [ ${#accesos_dia[@]} -eq 0 ]; then
            echo "No se encontraron accesos para la IP $OPCION."
        else
            # Iteramos sobre las claves (días) guardadas y mostramos la información
            for dia in $(printf "%s\n" "${!accesos_dia[@]}" | sort); do
                echo "Día: $dia | Accesos: ${accesos_dia[$dia]} | Bytes enviados: ${bytes_dia[$dia]}"
            done
        fi
        ;;
esac