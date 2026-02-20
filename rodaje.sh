#!/bin/bash
# ---------------------------------------------------------
# Script: rodaje.sh
# Autor: 
# Descripción:
#   Organiza vídeos con formato:
#   escena_XX_YYYY-MM-DDTHH:MM:SS.CAM
#   en la estructura:
#   destino/escenaXX/fecha/cam/
#   copiando el archivo y renombrándolo a escena_HH:MM
# ---------------------------------------------------------

# -------------------------------
# 1. COMPROBAR NÚMERO DE PARÁMETROS
# -------------------------------

# $# contiene el número de parámetros pasados al script
if [ $# -ne 2 ]; then
    # -ne significa "not equal" (distinto de)
    echo "Error: Debes pasar exactamente 2 parámetros."
    echo "Uso: ./rodaje.sh origen destino"
    exit 1   # exit 1 indica que el script termina con error
fi

# -------------------------------
# 2. GUARDAR PARÁMETROS EN VARIABLES
# -------------------------------

ORIGEN="$1"    # $1 es el primer parámetro
DESTINO="$2"   # $2 es el segundo parámetro

# -------------------------------
# 3. COMPROBAR QUE ORIGEN ES DIRECTORIO Y TIENE LECTURA
# -------------------------------

# -d comprueba si es directorio
# -r comprueba permiso de lectura
if [ ! -d "$ORIGEN" ] || [ ! -r "$ORIGEN" ]; then
    echo "Error: El origen no es un directorio válido o no tiene permisos de lectura."
    echo "Uso: ./rodaje.sh origen destino"
    exit 1
fi

# -------------------------------
# 4. COMPROBAR QUE DESTINO ES DIRECTORIO Y TIENE ESCRITURA
# -------------------------------

# -w comprueba permiso de escritura
if [ ! -d "$DESTINO" ] || [ ! -w "$DESTINO" ]; then
    echo "Error: El destino no es un directorio válido o no tiene permisos de escritura."
    echo "Uso: ./rodaje.sh origen destino"
    exit 1
fi

# -------------------------------
# 5. COMPROBAR QUE NO EXISTEN YA DIRECTORIOS escena20..escena50
# -------------------------------

for i in $(seq 20 50); do
    if [ -d "$DESTINO/escena$i" ]; then
        echo "Error: Ya existe el directorio $DESTINO/escena$i"
        echo "No se puede continuar."
        exit 1
    fi
done

# -------------------------------
# 6. CREAR DIRECTORIOS escena20..escena50
# -------------------------------

for i in $(seq 20 50); do
    mkdir "$DESTINO/escena$i"
done

# -------------------------------
# 7. RECORRER LOS ARCHIVOS DEL ORIGEN
# -------------------------------

# Recorremos todos los ficheros del directorio origen
for fichero in "$ORIGEN"/*; do

    # basename elimina la ruta y deja solo el nombre
    nombre=$(basename "$fichero")

    # Separar por "_" usando IFS
    # IFS es el separador interno de campos
    IFS="_" read -r parte1 parte2 parte3 <<< "$nombre"

    # parte1 = "escena"
    # parte2 = número de escena (ej: 20)
    # parte3 = fechaHora.camara (ej: 2023-02-11T17:04:00.Heat)

    escena="$parte2"

    # Separar fechaHora y cámara usando "."
    IFS="." read -r fechaHora camara <<< "$parte3"

    # fechaHora = 2023-02-11T17:04:00
    # camara = Heat

    # Separar fecha y hora usando "T"
    IFS="@" read -r fecha horaCompleta <<< "$fechaHora"

    # horaCompleta = 17:04:00

    # Obtener solo HH:MM (los primeros 5 caracteres)
    hora=${horaCompleta:0:5}

    # -------------------------------
    # 8. CREAR DIRECTORIO FINAL
    # -------------------------------

    rutaFinal="$DESTINO/escena$escena/$fecha/$camara"

    # -p crea todos los directorios necesarios si no existen
    mkdir -p "$rutaFinal"

    # -------------------------------
    # 9. COPIAR Y RENOMBRAR ARCHIVO
    # -------------------------------

    # Nuevo nombre: escena_HH:MM
    nuevoNombre="escena_$hora"

    cp "$fichero" "$rutaFinal/$nuevoNombre"

done

# -------------------------------
# FIN DEL SCRIPT
# -------------------------------

echo "Proceso completado correctamente."