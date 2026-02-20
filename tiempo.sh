#!/bin/bash
# Uso: ./tiempo.sh YYYY-MM-DD
# Ejemplo: ./tiempo.sh 2004-10-20

#uso
#chmod +x tiempo.sh
#./tiempo.sh 2004-10-20


#!/bin/bash
# La línea de arriba indica que el script se ejecuta con bash

# Comprobamos que se pasa exactamente 1 argumento
# $# = número de argumentos que recibe el script
# -ne = "not equal" (no igual)
if [ $# -ne 1 ]; then
    # $0 = nombre del script
    echo "Uso: $0 YYYY-MM-DD"
    exit 1   # Salimos con código de error
fi

# Guardamos el argumento en una variable
# $1 = primer argumento pasado al script
fecha="$1"

# Convertimos la fecha a segundos desde 1970 (timestamp)
# date -d permite interpretar una fecha
# +%s convierte la fecha a segundos
# 2>/dev/null evita que se muestren errores en pantalla
inicio=$(date -d "$fecha" +%s 2>/dev/null)

# Comprobamos si la fecha es válida
# -z comprueba si la variable está vacía
if [ -z "$inicio" ]; then
    echo "Fecha inválida. Usa formato YYYY-MM-DD"
    exit 1
fi

# Obtenemos el momento actual en segundos
ahora=$(date +%s)

# Comprobamos que la fecha no sea futura
# -gt = "greater than" (mayor que)
if [ "$inicio" -gt "$ahora" ]; then
    echo "La fecha debe ser anterior a hoy."
    exit 1
fi

# Inicializamos contador de años
años=0

# Bucle infinito que iremos rompiendo con break
while true; do

    # Calculamos el siguiente posible año completo
    siguiente=$((años + 1))
    # $(( )) se usa para hacer operaciones matemáticas

    # Calculamos la fecha sumando ese número de años
    ts=$(date -d "$fecha + $siguiente year" +%s 2>/dev/null)

    # Comprobamos si esa fecha todavía es menor o igual que ahora
    # -le = "less or equal" (menor o igual)
    if [ "$ts" -le "$ahora" ]; then
        años=$siguiente
    else
        break   # Si ya nos pasamos, salimos del bucle
    fi
done

# Calculamos la fecha base después de sumar los años completos
base=$(date -d "$fecha + $años year" +%s)

# Calculamos el resto de segundos desde ese aniversario
resto=$((ahora - base))

# 86400 = segundos en un día (24*60*60)
dias=$((resto / 86400))

# % = resto de la división
# resto % 86400 deja los segundos sobrantes del día actual
# luego dividimos entre 60 para convertir a minutos
minutos=$(((resto % 86400) / 60))

# Mostramos resultados
echo "Desde la fecha $fecha han pasado:"
echo "- $años años"
echo "- $dias días (dentro del último año)"
echo "- $minutos minutos (dentro del mismo día)"