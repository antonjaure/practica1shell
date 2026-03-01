#Código realizado por Elisa García García y Antón Jaureguizar Lombardero
#!/bin/bash

# Guardamos los argumentos en variables para que sea más fácil leer el código
opcion=$1

# "Toma el segundo parámetro ($2). 
# Si el usuario NO lo puso, usa un punto '.' (que significa 'directorio actual') por defecto".
dir=${2:-.}

# -d comprueba si "$dir" NO es un directorio válido.
# -z comprueba si la opción está vacía (zero length).
if [ ! -d "$dir" ] || [ -z "$opcion" ]; then
    echo "Uso: $0 [-a|-b|-c|-d|-e] [directorio]"
    exit 1
fi

# Intentamos entrar al directorio. 
# El || exit es un salvavidas: si el comando 'cd' falla (por falta de permisos, por ejemplo), 
# el script se cierra inmediatamente para no ejecutar el resto en la carpeta equivocada.
# || ejecuta el segundo comando si el primero falla 
cd "$dir" || exit

case $opcion in
    -a)
        # Bucle para recorrer todos los archivos (*) en el directorio actual
        for f in *; do
            # -e comprueba si el archivo existe 
            # || continue hace que si no existe, salte al siguiente ciclo del bucle sin hacer nada
            [ -e "$f" ] || continue
            
            # ${#f} calcula la LONGITUD (número de caracteres) del nombre del archivo.
            # Imprimimos: [longitud] [nombre_archivo]
            printf "%d %s\n" "${#f}" "$f"
       
        # sort -n : Ordena numéricamente (por la longitud que acabamos de calcular)
        # cut -d' ' -f2- : Corta por el espacio y se queda desde la columna 2 hasta el final (-f2-). 
        # Esto sirve para borrar el número de la longitud y mostrar solo el nombre ya ordenado.
        done | sort -n | cut -d' ' -f2-
        ;;

    -b)

        # 1. ls -1 : Lista los archivos (uno por línea).
        # 2. rev : Le da la vuelta al texto
        # 3. sort : Ordena alfabéticamente
        # 4. rev : Le vuelve a dar la vuelta para que se lea normal.
        ls -1 | rev | sort | rev
        ;;

    -c)
        # stat extrae metadatos de los archivos. La opcion -c es la que permite usar formatos: %i es el Inodo, %n es el nombre.
        # read -r "raw" evita que se interpreten caracteres especiales
        stat -c "%i %n" * | while read -r inode nombre; do
            # ${variable: -4} toma los últimos 4 caracteres.
            ultimos=${inode: -4}
            
            # Imprime: [ultimos 4 digitos] [inodo completo] [nombre]
            printf "%s %s %s\n" "$ultimos" "$inode" "$nombre"
        # sort -rn : Ordena numéricamente (n) y en reversa/de mayor a menor (r).
        # cut -d' ' -f2- : Borra la primera columna (los 4 dígitos) dejando solo el Inodo y el Nombre.
        done | sort -rn | cut -d' ' -f2-
        ;;

    -d)
        # stat extrae: %a (Permisos en formato octal ej: 755), %s (Tamaño en bytes), %n (Nombre)
        stat -c "%a %s %n" * | while read -r perm tam nombre; do
            # ${perm:0:1} extrae desde la posición 0, 1 solo carácter (el permiso del propietario)
            propietario_perm=${perm:0:1}
            echo "Grupo Propietario: $propietario_perm | Tamaño: $tam | Archivo: $nombre"
        # sort -k3,3n -k6,6n : Ordena primero por la columna 3 (permiso) numéricamente, 
        # y si empatan, por la columna 6 (tamaño) numéricamente.
        done | sort -k3,3n -k6,6n
        ;;

    -e)
        # stat extrae: %x (Fecha de acceso), %i (Inodo), %n (Nombre)
        stat -c "%x %i %n" * | while read -r fecha hora zona inode nombre; do
            # Extrae el mes usando cut (asumiendo que la fecha viene en formato YYYY-MM-DD)
            mes=$(echo "$fecha" | cut -d'-' -f2)
            echo "Mes Acceso: $mes | Inode: $inode | Archivo: $nombre"
        # Ordena por el mes (columna 3) y luego por el inodo (columna 6)
        done | sort -k3,3n -k6,6n
        ;;

    *)
        # Si no metió ni -a, ni -b, ni -c, etc.
        echo "Opción no válida."
        ;;
esac