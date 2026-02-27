#!/bin/bash

# Comprobar que se pasa un fichero
if [ $# -ne 1 ]; then
    echo "Uso: $0 agenda.txt"
    exit 1
fi

AGENDA=$1

# Si no existe, lo crea
touch $AGENDA

while true
do
    echo "----- AGENDA -----"
    echo "1. Nueva agenda (vaciar)"
    echo "2. Añadir cliente"
    echo "3. Buscar por nombre"
    echo "4. Buscar por email"
    echo "5. Modificar cliente"
    echo "6. Borrar cliente"
    echo "7. Ver agenda"
    echo "0. Salir"
    read opcion

    case $opcion in

    1)
        > $AGENDA
        echo "Agenda vaciada"
        ;;

    2)
        echo "Nombre:"
        read nombre
        echo "Email:"
        read email

        # Si el fichero NO acaba en salto de línea, añade uno
        # tail -c 1 lee el último carácter; si no es vacío, no había salto
        if [ -s "$AGENDA" ] && [ -n "$(tail -c 1 "$AGENDA")" ]; then
            echo >> "$AGENDA"
        fi

        echo "$nombre#$email" >> "$AGENDA"
        echo "Cliente añadido"
        ;;

    3)
       
        echo "Nombre a buscar:"
        read nombre
        grep "^$nombre#" "$AGENDA"
        ;;
    4)
        echo "Email a buscar:"
        read email
        grep "$email" $AGENDA
        ;;

    5)
        echo "Nombre exacto a modificar:"
        read nombre
        echo "Nuevo nombre:"
        read nuevo_nombre
        echo "Nuevo email:"
        read nuevo_email

        # sustituye la línea que empiece por nombre#
        sed -i "s/^$nombre#.*/$nuevo_nombre#$nuevo_email/" $AGENDA
        echo "Cliente modificado"
        ;;

    6)
        echo "Nombre exacto a borrar:"
        read nombre

        # borra línea que empiece por nombre#
        sed -i "/^$nombre#/d" $AGENDA
        echo "Cliente borrado"
        ;;

    7)
        cat $AGENDA
        ;;

    0)
        exit 0
        ;;

    *)
        echo "Opción no válida"
        ;;
    esac

    echo ""
done