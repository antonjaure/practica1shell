#Código realizado por Elisa García García y Antón Jaureguizar Lombardero
#!/bin/bash

# $# contiene el número de parámetros pasados al script
# -ne "not equal" es decir si no son 2 da error
if [ "$#" -ne 2 ]; then
    echo "Error: Número de parámetros incorrecto."
    echo "Uso: $0 [-c | GET/POST | -s | -t | -o | IP] ruta/access.log"
    exit 1
fi

OPCION="$1"
ARCHIVO="$2"

# -f "is file" comprueba si es un archivo regular
# -r "is readable" comprueba si tiene permisos de lectura
# || "OR" lógico: si NO es archivo O NO es legible, da error
if [ ! -f "$ARCHIVO" ] || [ ! -r "$ARCHIVO" ]; then
    echo "Error: El archivo '$ARCHIVO' no existe, no es un archivo regular o no tiene permisos de lectura."
    echo "Uso: $0 [-c | GET/POST | -s | -t | -o | IP] ruta/access.log"
    exit 1
fi

case "$OPCION" in
    -c)
        # cut -d' ' corta marcando los espacios como separadores
        #-f9: coge la columna 9 (código HTTP)
        # sort: ordena los códigos
        # uniq -c: elimina lineas consecutivas duplicada (la opcion -c hace que las cuente)
        # while read count code: lee linea a linea, guarda la primera parte en count y la segunda en code y los imprime
        cut -d' ' -f9 "$ARCHIVO" | sort | uniq -c | while read count code; do
            echo "Código $code: $count veces"
        done
        ;;

    -t)
        # Extrae la fecha (columna 4), quita el corchete '[' y la hora ':', dejando solo 'DD/MMM/YYYY'
        # sort -u: deja solo las fechas únicas
        fechas=$(cut -d' ' -f4 "$ARCHIVO" | cut -d'[' -f2 | cut -d':' -f1 | sort -u)
        min_epoch=20000000000 # Un valor inicial muy alto para buscar el mínimo
        max_epoch=0 # Un valor inicial de 0 para buscar el máximo
        dias_con_acceso=0
        
        export LC_TIME=en_US.UTF-8 # Asegura que el comando date entienda meses en inglés (Jan, Feb...)

        # Bucle para convertir cada fecha a segundos (epoch) y buscar el primer y último día de acceso
        for f in $fechas; do
            f_espacios="${f//\// }" # Reemplaza las barras '/' por espacios para que date lo entienda bien
            epoch=$(date -d "$f_espacios" +%s 2>/dev/null) # Convierte a segundos desde 1970
            #si da error (2) redirige la salida a /dev/null para que no se muestre el error

            if [ -n "$epoch" ]; then # -n comprueba si la variable NO está vacía (por si date falló)
                ((dias_con_acceso++)) #incrementa el contador 
                # Actualiza el mínimo y máximo
                [ "$epoch" -lt "$min_epoch" ] && min_epoch=$epoch
                [ "$epoch" -gt "$max_epoch" ] && max_epoch=$epoch
            fi
        done
        
        #si dias con acceso mayor que 0
        if [ "$dias_con_acceso" -gt 0 ]; then
            # Calcula los días totales transcurridos restando el max y min, dividiendo por los segundos de un día (86400)
            dias_totales=$(( (max_epoch - min_epoch) / 86400 + 1 ))
            # Imprime los días SIN acceso (días totales de rango - días que sí tuvieron acceso)
            echo $((dias_totales - dias_con_acceso))
        else
            echo "0"
        fi
        ;;

    GET|POST)
        cantidad=0
        # read -r asigna cada palabra separada por espacios a una variable. 
        # Si sobran columnas, van a 'resto'.
        while read -r ip guion1 guion2 fecha_hora zona metodo url protocolo codigo bytes resto; do
            metodo_limpio="${metodo#\"}" # Quita las comillas dobles (") al principio del método (ej: "GET -> GET)
            
            # Si el método coincide con la opción (GET o POST) y el código es 200 (OK) incrementa el contador
            if [ "$metodo_limpio" = "$OPCION" ] && [ "$codigo" = "200" ]; then
                ((cantidad++))
            fi
        done < "$ARCHIVO" # Le pasamos el archivo de log al bucle while

        # Obtenemos la fecha actual para el print final
        fecha_exec=$(LANG=en_US.UTF-8 date "+%b %d %H:%M:%S")
        echo "${fecha_exec}. Registrados ${cantidad} accesos tipo $OPCION con respuesta 200."
        ;;

    -s)
        # declare -A crea "Arrays Asociativos" (como un Hashmap clave-valor)
        declare -A sum_mes
        declare -A acc_mes

        while read -r ip guion1 guion2 fecha_hora zona metodo url protocolo codigo bytes resto; do
            fecha_limpia="${fecha_hora#\[}"   #Quita el primer corchete '['
            mes="${fecha_limpia#*/}"  # Borra todo hasta la primera barra (quita el día)
            mes="${mes%%/*}" # Borra todo desde la última barra (quita el año y hora), dejando solo el Mes
            
            # En los logs, si no se envían bytes aparece un guion '-'. Lo cambiamos a 0 para poder sumar.
            # el operador && ejecuta el segundo comando solo si el primero es verdadero (es decir, si bytes es '-')
            [ "$bytes" = "-" ] && bytes=0
            
            ((sum_mes[$mes]+=$bytes)) # Suma los bytes a la clave de ese mes
            ((acc_mes[$mes]++)) # Suma 1 a los accesos de ese mes
        done < "$ARCHIVO"

        # ${!sum_mes[@]} extrae todas las claves (los meses) sin ! te devuelve los valores
        for m in "${!sum_mes[@]}"; do
            kib=$(( sum_mes[$m] / 1024 )) # Convierte los bytes totales a Kilobytes
            echo "$kib KiB sent in $m by ${acc_mes[$m]} accesses."
        done
        ;;

    -o)
        # sort ordena el archivo de forma avanzada:
        # -t ' ' : Usa el espacio como separador
        # -k1,1  : Ordena primero por la columna 1 (IP) alfabéticamente
        # -k10,10nr : Luego ordena por la columna 10 (Bytes) de forma Numérica (n) y Descendente (r)
        sort -t ' ' -k1,1 -k10,10nr "$ARCHIVO" > access_ord.log
        echo "Resultado guardado en access_ord.log"
        ;;

    *)
        # Este bloque actúa como el "default" del switch case.
        # Si no fue -c, -t, GET, POST, -s ni -o, asume que el usuario introdujo una IP.
        declare -A accesos_dia
        declare -A bytes_dia

        while read -r ip guion1 guion2 fecha_hora zona metodo url protocolo codigo bytes resto; do
            # Solo procesamos si la IP de esta línea coincide con la opción que nos pasaron
            if [ "$ip" = "$OPCION" ]; then
                fecha_limpia="${fecha_hora#\[}"
                dia="${fecha_limpia%%:*}" # Borra desde los dos puntos ':' en adelante para quedarse solo con la fecha
                
                [ "$bytes" = "-" ] && bytes=0 # Si hay un guion en lugar de bytes, cámbialo a 0
                
                ((accesos_dia[$dia]++))
                ((bytes_dia[$dia]+=$bytes))
            fi
        done < "$ARCHIVO"

        # ${#accesos_dia[@]} cuenta cuántos elementos tiene el array. Si es 0, la IP no estaba en el log.
        if [ ${#accesos_dia[@]} -eq 0 ]; then
            echo "No se encontraron accesos para la IP $OPCION."
        else
            # Imprime los resultados ordenando por fecha (clave del diccionario)
            for dia in $(printf "%s\n" "${!accesos_dia[@]}" | sort); do
                echo "Día: $dia | Accesos: ${accesos_dia[$dia]} | Bytes enviados: ${bytes_dia[$dia]}"
            done
        fi
        ;;
esac