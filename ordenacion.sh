#!/bin/bash

opcion=$1
dir=${2:-.}

if [ ! -d "$dir" ] || [ -z "$opcion" ]; then
    echo "Uso: $0 [-a|-b|-c|-d|-e] [directorio]"
    exit 1
fi

# Función auxiliar para procesar archivos uno a uno
cd "$dir" || exit

case $opcion in
    -a)
        # Longitud del nombre: calculamos ${#fichero} y ordenamos
        for f in *; do
            [ -e "$f" ] || continue
            printf "%d %s\n" "${#f}" "$f"
        done | sort -n | cut -d' ' -f2-
        ;;
    -b)
        # Alfabético al revés: rev -> sort -> rev
        ls -1 | rev | sort | rev
        ;;
    -c)
        # Últimos 4 dígitos del inode (mayor a menor)
        stat -c "%i %n" * | while read -r inode nombre; do
            # Extraemos los últimos 4 caracteres usando expansión de Bash
            ultimos=${inode: -4}
            printf "%s %s %s\n" "$ultimos" "$inode" "$nombre"
        done | sort -rn | cut -d' ' -f2-
        ;;
    -d)
        # Permisos rwx (octal), tamaño y nombre
        # El primer dígito de %a es el del propietario
        stat -c "%a %s %n" * | while read -r perm tam nombre; do
            propietario_perm=${perm:0:1}
            echo "Grupo Propietario: $propietario_perm | Tamaño: $tam | Archivo: $nombre"
        done | sort -k3,3n -k6,6n
        ;;
    -e)
        # Inode agrupados por mes de acceso
        # %x da la fecha, %i el inode
        stat -c "%x %i %n" * | while read -r fecha hora zona inode nombre; do
            # La fecha viene como AAAA-MM-DD, extraemos el mes (MM)
            mes=$(echo "$fecha" | cut -d'-' -f2)
            echo "Mes Acceso: $mes | Inode: $inode | Archivo: $nombre"
        done | sort -k3,3n -k6,6n
        ;;
    *)
        echo "Opción no válida."
        ;;
esac