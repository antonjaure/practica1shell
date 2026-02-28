#Código realizado por Elisa García García y Antón Jaureguizar Lombardero
#!/bin/bash

#  $# contiene el número de parámetros pasados al script
# -ne "not equal"
if [ $# -ne 1 ]; then
    echo "Uso: $0 YYYY-MM-DD" # $0 es el nombre del script
    exit 1
fi

fecha="$1"
inicio=$(date -d "$fecha" +%s 2>/dev/null) 
#date -d convierte la fecha (en la variable fecha) a segundos desde 1970 y la mete a inicio.
#2>/dev/null redirige cualquier mensaje de error a la nada.
#1 es el stdout (salida normal), 2 es el stderr (salida de error).

# -z "is zero" mira si la variable esta vacía, para ver que inicio se asgino correctamente.
if [ -z "$inicio" ]; then
    echo "Fecha inválida. Usa formato YYYY-MM-DD"
    exit 1
fi

ahora=$(date +%s) # Obtenemos el tiempo actual en segundos desde 1970

#-gt "greater than"
if [ "$inicio" -gt "$ahora" ]; then
    echo "La fecha debe ser anterior a hoy."
    exit 1
fi

# COMPROBACIÓN DEL CALENDARIO (AÑO 1582)

# %% busca la primera coincidencia con "-" y elimina todo hasta final de cadena.
# % haría los mismo pero con la ultima coincidencia.
# "#" buscaria la primera coincidencia y eliminaria lo que este antes
ano_input="${fecha%%-*}"
ajuste_dias=0

# -lt "less than"
if [ "$ano_input" -lt 1582 ]; then
    echo "Fecha anterior a 1582. Se descontarán 10 días por el ajuste del calendario juliano al gregoriano."
    ajuste_dias=10
fi


anos=0 #contador de años
while true; do
    siguiente=$((anos + 1)) #actualiza el contador

    #Le sumo a la fecha original el numero de años que llevo contado
    # %s convierte esa nueva fecha a segundos desde 1970, y lo guardo en ts.
    # si es error (2) redirijo la salida a /dev/null
    ts=$(date -d "$fecha + $siguiente year" +%s 2>/dev/null) 

    #Si la fecha es menor o igual a la fecha actual sigo contando años, si no, salgo del bucle.
    if [ "$ts" -le "$ahora" ]; then
        anos=$siguiente
    else
        break
    fi
done

# Ahora que ya tengo los años se los resto a la fecha original para calcular los días y minutos restantes.
base=$(date -d "$fecha + $anos year" +%s)
resto=$((ahora - base))

# Calculamos días y minutos iniciales
dias=$((resto / 86400)) #como esta en segundos divido entre el numero de segundos que tiene un día
minutos=$(((resto % 86400) / 60)) #calculo los minutos

#aplicamos el ajuste de dias (es 0 si la fecha es posterior a 1582, y 10 si es anterior)
dias=$((dias - ajuste_dias))

# Si al restar los 10 días nos quedamos en negativo, 
# restamos 1 año y sumamos 365 días para compensar.
if [ "$dias" -lt 0 ]; then
    anos=$((anos - 1))
    dias=$((dias + 365))
fi

#prints
echo "Desde la fecha $fecha han pasado:"
echo "- $anos años"
echo "- $dias días (dentro del último año)"
echo "- $minutos minutos (dentro del mismo día)"