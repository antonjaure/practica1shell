#Código realizado por Elisa García García y Antón Jaureguizar Lombardero
#!/bin/bash

# Comprobar número de parámetros
if [ $# -ne 1 ]; then # Si no se pasa exactamente 1 parámetro, mostramos un mensaje de error y terminamos con exit 1 (indica error)
   #$# : contiene el número de parámetros pasados al script
    echo "ERROR Recuerda el uso: $0 agenda.txt"
    # $0 : contiene el nombre del script, en este caso clientes.sh
    exit 1
fi

# Guardar el nombre del fichero de agenda en una variable
AGENDA=$1 # $1 : contiene el primer parámetro pasado al script, que en este caso es el nombre del fichero de agenda.

touch $AGENDA # touch crea el fichero si no existe, o actualiza su fecha de modificación si ya existe. 
#Así nos aseguramos de que el fichero de agenda existe antes de intentar leerlo o escribir en él.


while true # Bucle infinito para mostrar el menú hasta que el usuario decida salir.
do
    echo "        AGENDA "
    echo "1. Nueva agenda (vacia la actual)"
    echo "2. Registrar una nueva entrada en la agenda"
    echo "3. Buscar por nombre"
    echo "4. Buscar por email"
    echo "5. Modificar una entrada"
    echo "6. Borrar una entrada"
    echo "0. Salir"
    read opcion # read lee la opción elegida por el usuario y la guarda en la variable opcion.

    case $opcion in # case evalúa el valor de opcion y ejecuta el bloque de código correspondiente según la opción elegida.

    1)
        > $AGENDA # > $AGENDA vacía el contenido del fichero de agenda, dejándolo sin clientes.
        # >: redirige la salida estándar a un fichero. Si el fichero existe, se sobrescribe con el nuevo contenido. Si el fichero no existe, se crea uno nuevo.
        #En este caso, al no escribir nada antes de > $AGENDA, lo que hacemos es vaciar el contenido del fichero.
        echo "Nueva agenda creada, la actual ha sido vaciada"
        ;; # ;; indica el final del bloque de código para la opción 1.

    2)
        echo "Nombre:"
        read nombre # read lee el nombre del cliente introducido por el usuario y lo guarda en la variable nombre.
        echo "Email:"
        read email #lo mismo con email

       # Antes de añadir el cliente, comprobamos si el fichero no está vacío y si la última línea no termina con un salto de línea. Si es así, añadimos un salto de línea para separar el nuevo cliente del anterior.
       # -s: comprueba si el fichero tiene tamaño mayor que cero (no está vacío).
       # -n: comprueba si la cadena no está vacía. 
       #Usamos tail -c 1 "$AGENDA" para obtener el último carácter del fichero de agenda, y comprobamos si no es un salto de línea. 
       #Si el último carácter no es un salto de línea lo añaddimos con el comando echo >> "$AGENDA".
        if [ -s "$AGENDA" ] && [ -n "$(tail -c 1 "$AGENDA")" ]; then
            echo >> "$AGENDA" # echo >> "$AGENDA" añade un salto de línea al final del fichero de agenda.
        fi

        echo "$nombre#$email" >> "$AGENDA" # añade una nueva línea al final del fichero de agenda con el formato nombre#email, donde nombre y email son los valores introducidos por el usuario.
        # >> "$AGENDA" redirige la salida del comando echo al final del fichero de agenda, añadiendo el nuevo cliente sin sobrescribir los anteriores.
        echo "Nueva entrada añadida"
        ;;

    3)
       
        echo "Nombre a buscar:"
        read nombre
        grep "^$nombre#" "$AGENDA" 
        # grep busca líneas que coincidan con el patrón especificado. 
        #En este caso, el patrón es "^$nombre#", que significa: buscar líneas que empiecen (^) con el nombre introducido por el usuario seguido de un #.
        #Si el cliente existe en la agenda, se mostrará su nombre y email. Si no existe, no se mostrará nada.
        ;;
    4)
        echo "Email a buscar:"
        read email
        grep "$email" $AGENDA # grep busca líneas que contengan el email introducido por el usuario en el fichero de agenda.
        #Si el email existe en la agenda, se mostrará el nombre y email del cliente. Si no existe, no se mostrará nada.
        ;;

    5)
        echo "Nombre exacto a modificar:"
        read nombre
        echo "Nuevo nombre:"
        read nuevo_nombre
        echo "Nuevo email:"
        read nuevo_email

       # Para modificar un cliente, usamos sed para buscar la línea que empieza con el nombre exacto introducido por el usuario seguido de un #, 
       #y reemplazamos esa línea por una nueva línea con el nuevo nombre y nuevo email.
       # -i: edit in place, modifica el fichero directamente.
    # "s/^$nombre#.*/$nuevo_nombre#$nuevo_email/": es la expresión de sustitución de sed, que significa: buscar líneas que empiecen (^) con el nombre exacto seguido de un # y cualquier cosa después (.*), 
    #y reemplazar esa línea por una nueva línea con el nuevo nombre y nuevo email en el formato nuevo_nombre#nuevo_email.
    #s/: indica que es una sustitución.
    #^$nombre#: busca líneas que empiecen con el nombre exacto seguido de un #.
    #.*: coincide con cualquier cosa después del nombre# (el email actual), y lo reemplaza por el nuevo nombre y nuevo email.
         # $AGENDA: es el fichero de agenda donde se realizará la sustitución.
        sed -i "s/^$nombre#.*/$nuevo_nombre#$nuevo_email/" $AGENDA
        echo "Entrada modificada"
        ;;

    6)
        echo "Nombre exacto a borrar:"
        read nombre

        # Para borrar un cliente, usamos sed para eliminar la línea que empieza con el nombre exacto introducido por el usuario seguido de un #.
        # -i: edit in place, modifica el fichero directamente.
        # /^$nombre#/d: es la expresión de sed que significa: buscar líneas que empiecen (^) con el nombre exacto seguido de un #, y eliminar esa línea (d).
            # $AGENDA: es el fichero de agenda donde se realizará la eliminación.
        sed -i "/^$nombre#/d" $AGENDA
        echo "Entrada borrada"
        ;;

    0)
        exit 0
        # exit 0 termina el script con un código de salida 0, que indica que el programa ha finalizado correctamente. 
        ;;

    *)
        echo "Opción no válida"
        ;;
    esac # El bloque case termina aquí, y el bucle while se repetirá mostrando el menú de nuevo hasta que el usuario elija la opción 0 para salir.

    echo "" # Imprime una línea vacía para separar cada iteración del menú.

done
