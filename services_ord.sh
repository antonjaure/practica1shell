#Código realizado por Elisa García García y Antón Jaureguizar Lombardero
#!/bin/bash

# Ordenar y eliminar duplicados
sort ~/services_copia | uniq > /tmp/services_original
# sort ~/services_copia: Ordena todas las líneas del fichero alfabéticamente. útil para luego aplicar el unique.
#uniq:  Elimina líneas repetidas consecutivas (porque ya está ordenado. Si hay dos líneas iguales separadas, uniq no las detecta si no está ordenado).
# > /tmp/services_original: Redirige el resultado a un fichero temporal en /tmp.


# Contar líneas
original=$(wc -l < ~/services_copia)
# wc -l cuenta el número de líneas.
# El < ~/services_copia hace que wc lea del fichero por stdin, y así NO imprime el nombre del fichero, solo el número.
# original=$.. guarda ese número en la variable original.
nuevo=$(wc -l < /tmp/services_original)
#lo mimsmo

#echo: muestra texto por pantalla
echo "Líneas originales: $original"
echo "Líneas después de eliminar duplicados: $nuevo"
echo "Líneas eliminadas: $((original - nuevo))"

# Comprobación correcta (sin comentarios ni vacías)
echo "Comprobando equivalencia con /etc/services (sin comentarios ni vacías)"
diff <(grep -vE '^\s*($|#)' /etc/services | sort | uniq) \
     <(grep -vE '^\s*($|#)' /tmp/services_original | sort | uniq)
     #grep sirve para buscar patrones dentro de un fichero.
     #-v : Invierte el resultado.
     #-E: Permite usar expresiones regulares extendidas: usar |
     #^\s*: Cero o más espacios o tabs
     #($|#): $ es fin de línea o rollo linea vacia y # es comentario


# diff compara dos ficheros línea a línea: Si no hay diferencias -> exit code 0 y si hay diferencias -> exit code 1 (y muestra qué cambia).

#-eq significa equal
if [ $? -eq 0 ]; then #Si el último comando devolvió 0, entonces
  echo "Los ficheros son equivalentes."
else
  echo "Hay diferencias."
fi
# $? guarda el código de salida del último comando ejecutado.
# 0  => sin diferencias, todo bien
# !=0=> con diferencias