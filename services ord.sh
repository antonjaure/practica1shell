#Ordenar alfabéticamente services_copia

##Eliminar líneas duplicadas

#Guardar el resultado en /tmp/services_original

#Indicar cuántas líneas se eliminaron

#Comprobar que es equivalente a /etc/services usando diff y sort*/
#!/bin/bash

# Ordenar y eliminar duplicados
sort ~/services_copia | uniq > /tmp/services_original

# Contar líneas
original=$(wc -l < ~/services_copia)
nuevo=$(wc -l < /tmp/services_original)

echo "Líneas originales: $original"
echo "Líneas después de eliminar duplicados: $nuevo"
echo "Líneas eliminadas: $((original - nuevo))"

# Comprobación
echo "Comprobando equivalencia con /etc/services..."
diff <(sort /etc/services) <(sort /tmp/services_original)



# Comprobación (ignorando comentarios y líneas vacías)
#echo "Comprobando equivalencia con /etc/services (sin comentarios)..."
#diff <(grep -vE '^\s*($|#)' /etc/services | sort) \ <(grep -vE '^\s*($|#)' /tmp/services_original | sort)
     


if [ $? -eq 0 ]; then #Si el código de salida del último comando es igual a 0...
#-eq significa "igual a"
    echo "Los ficheros son equivalentes."
else
    echo "Hay diferencias."
fi
#$? guarda el código de salida del último comando ejecutado.
#el último comando antes del if es: diff ...