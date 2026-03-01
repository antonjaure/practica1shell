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

        # Crear un fichero temporal usando mktemp
        temporal1=$(mktemp) 
        # Comprobar si mktemp ha fallado
        if [ $? -ne 0 ]; then # $? contiene el código de salida del último comando ejecutado. 
        #Si mktemp ha fallado, devolverá un código de salida diferente de 0.
            echo "Error creando temporal"
            exit 1
        fi
        # mktemp crea un fichero temporal de forma segura y devuelve su nombre. 
        # Si ocurre un error al crear el temporal, se muestra un mensaje de error y el script termina con exit 1.


        modificado=0 #bandera. si se encuentra el cliente a modificar, se cambia a 1 para indicar que se ha modificado la entrada. 
        #Si al finalizar la lectura del fichero de agenda modificado sigue siendo 0, significa que no se ha encontrado el cliente a modificar.
        
        while IFS="#" read -r n e; do # lee el fichero de agenda línea por línea, separando el nombre y email por el carácter #.
            # Si hay líneas vacías, las copiamos tal cual
            #IFS="#" establece el carácter # como separador de campos para el comando read, permite leer el nombre y emailç incluso si contienen espacios.
           # read -r : lee una línea de entrada y la divide en campos según el separador definido por IFS.
           #n y e son las variables donde se almacenan el nombre y email leídos de cada línea del fichero de agenda.
            if [ -z "$n" ] && [ -z "$e" ]; then
            # -z: comprueba si la cadena está vacía. comprobamos si tanto el nombre n y el email e están vacíos, lo que indicaría una línea vacía en el fichero de agenda.
                echo "" >> "$temporal1" 
            # añadimos una línea vacía al fichero temporal para mantener la estructura del fichero de agenda original, incluyendo las líneas vacías.
                continue 
                # hace que el bucle while pase a la siguiente iteración sin ejecutar el resto del código dentro del bucle para esa línea vacía.
            fi

            # Si el nombre coincide con el nombre a modificar y 
            #aún no se ha modificado, 
            if [ "$n" = "$nombre" ] && [ $modificado -eq 0 ]; then
            # -eq: compara , si el nombre leído n es igual al nombre exacto a modificar introducido por el usuario, bandera modificado = 0 (no modificado).
                echo "$nuevo_nombre#$nuevo_email" >> "$temporal1"
                #escribimos la nueva entrada en el fichero temporal con el formato nuevo_nombre#nuevo_email.
                modificado=1 #macramos como modificado
            else
                echo "$n#$e" >> "$temporal1"
                # sino copiamos la línea original al fichero temporal sin cambios.
            fi
        done < "$AGENDA" #done: indica el final del bucle while,
        # < "$AGENDA" redirige el contenido del fichero de agenda como entrada para el bucle while asi permite leer el fichero línea por línea.

        mv "$temporal1" "$AGENDA" # mv mueve el fichero temporal al fichero de agenda, reemplazando el contenido original por el nuevo contenido modificado.

        if [ $modificado -eq 1 ]; then # si se ha modificado la entrada, mostramos un mensaje de confirmación. 
            echo "Entrada modificada"
        else
            echo "No existe ese nombre"
        fi
        ;;
     

    6)
    #igual que en la opcion 5 pero sin modificar la entrada, 
    #no la copiamos al fichero temporal para que quede borrada.
        echo "Nombre exacto a borrar:"
        read nombre

        temporal2=$(mktemp) 
        # Comprobar si mktemp ha fallado
        if [ $? -ne 0 ]; then # $? contiene el código de salida del último comando ejecutado. 
        #Si mktemp ha fallado, devolverá un código de salida diferente de 0.
            echo "Error creando temporal"
            exit 1
        fi

        borrado=0
        while IFS="#" read -r n e; do
            # Mantener líneas vacías si las hubiera
            if [ -z "$n" ] && [ -z "$e" ]; then
                echo "" >> "$temporal2"
                continue
            fi

            if [ "$n" = "$nombre" ] && [ $borrado -eq 0 ]; then
                borrado=1
                continue  # saltamos esa línea, no la copiamos
            fi

            echo "$n#$e" >> "$temporal2"
        done < "$AGENDA"

        mv "$temporal2" "$AGENDA"

        if [ $borrado -eq 1 ]; then
            echo "Entrada borrada"
        else
            echo "No existe ese nombre"
        fi
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