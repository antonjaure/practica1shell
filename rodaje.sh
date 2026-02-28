#Código realizado por Elisa García García y Antón Jaureguizar Lombardero
#!/bin/bash

# comprobar número de parámetros.
# $# contiene el número de parámetros pasados al script
# -ne: "not equal" 
if [ $# -ne 2 ]; then # Si no se pasan exactamente 2 parámetros, mostramos un mensaje de error y terminamos con exit 1 (indica error)
    echo "Error, puesto que debes pasar exactamente 2 parámetros."
    echo "Uso: ./rodaje.sh origen destino"

    exit 1   
    # exit 1 indica que el script termina con error
fi

# guardar parámetros en variables con nombres 
ORIGEN="$1"
# $1 es el primer parámetro que se le pasa al script, que en este caso es el directorio de origen 
DESTINO="$2"   
# $2 es el segundo 


#comprobar que origen es directorio y tiene lectura
# -d comprueba si es directorio
# -r comprueba permiso de lectura
if [ ! -d "$ORIGEN" ] || [ ! -r "$ORIGEN" ]; then
    echo "Error ya que el origen no es un directorio válido o no tiene permisos de lectura."
    exit 1
fi


# comprobar que destino tiene directorio y tambien escritura
# -w comprueba permiso de escritura
if [ ! -d "$DESTINO" ] || [ ! -w "$DESTINO" ]; then
    echo "Error: El destino no es un directorio válido o no tiene permisos de escritura."
    exit 1
fi

# comprobar que no existen ya directorios rollo escena20...al50  
for i in $(seq 20 50); do # seq genera una secuencia de números, en este caso del 20 al 50, y el for itera sobre cada número de esa secuencia.
    if [ -d "$DESTINO/escena$i" ]; then # -d comprueba si el directorio existe. Si existe, mostramos un mensaje de error y terminamos con exit 1 (indica error)
    #$i: es el número de escena que estamos comprobando, ej: escena20
        echo "No se puede continuar por error ya existe el directorio $DESTINO/escena$i"
        exit 1
    fi
done # Si el bucle termina sin encontrar ningún directorio existente, entonces continuamos con el resto del script.


# Ahora creamos los directorios escena20...al50 dentro del destino, ya que hemos comprobado que no existen
for i in $(seq 20 50); do # seq genera una secuencia de números, en este caso del 20 al 50, y el for itera sobre cada número de esa secuencia.
    mkdir "$DESTINO/escena$i"
    # mkdir crea un directorio con el nombre especificado, en este caso $DESTINO/escena$i.
done # Si el bucle termina, entonces ya tenemos creados los directorios escena20...al50 dentro del destino, y podemos continuar con el resto del script.


# recorremos todos los ficheros del directorio origen
for fichero in "$ORIGEN"/*; do
    # basename elimina la ruta y deja solo el nombre
    nombre=$(basename "$fichero") 
    # Para cada fichero, vamos a extraer la información necesaria para organizarlo en el destino.
    #con nombre=$(basename "$fichero") obtenemos el nombre del fichero sin la ruta, por ejemplo: escena20_2023-02-11T17:04:00.Heat

    # Separar por "_" usando IFS
    # IFS es el separador interno de campos
    IFS="_" read -r parte1 parte2 parte3 <<< "$nombre"
    #read -r: lee la línea de entrada y la divide en campos según el separador IFS.
    # parte1 = "escena"
    # parte2 = número de escena ej: 20
    # parte3 = fechaHora.camara ej: 2023-02-11T17:04:00.Heat


    escena="$parte2" 

# Ahora tenemos la escena, pero necesitamos la fecha y la cámara para organizarlo en el destino. 
#La parte3 tiene el formato fechaHora.camara, así que vamos a separarlo por "." usando IFS de nuevo.
    # Separar fechaHora y cámara usando "."
    IFS="." read -r fechaHora camara <<< "$parte3"
    #con los <<< "$parte3" hacemos que el comando read lea de la variable parte3 en lugar de leer de stdin.
    # fechaHora = 2023-02-11T17:04:00
    # camara = Heat


    # Separar fecha y hora usando @
    IFS="@" read -r fecha horaCompleta <<< "$fechaHora"
    # fecha = 2023-02-11
    # horaCompleta = 17:04:00

    # Obtener solo HH:MM los primeros 5 caracteres
    hora=${horaCompleta:0:5} 
    # con ${horaCompleta:0:5} obtenemos una subcadena de horaCompleta que empieza en el índice 0 y tiene una longitud de 5 caracteres. Los primeros 5 caracteres que corresponden a HH:MM.

    
    # crear directorio final 
    rutaFinal="$DESTINO/escena$escena/$fecha/$camara"
# Con la información que hemos extraído, podemos construir la ruta final donde se debe copiar el fichero. 
#La ruta final tiene el formato de $DESTINO/escenaX/fecha/camara, donde X es el número de escena, 
#fecha es la fecha extraída y camara es la cámara extraída.

    # -p crea todos los directorios necesarios si no existen
    mkdir -p "$rutaFinal"
    # mkdir -p "$rutaFinal" crea el directorio especificado en rutaFinal,
    #si alguno de los directorios intermedios no existe, también lo crea. 

    # copiar y renonmbrar el fichero. Nuevo nombre es escena_HH:MM
    nuevoNombre="escena_$hora"

    cp "$fichero" "$rutaFinal/$nuevoNombre"
    # copia el fichero original a la ruta final con el nuevo nombre.

done # El bucle termina cuando se han procesado todos los ficheros del directorio origen.