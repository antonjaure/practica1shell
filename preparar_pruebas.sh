#!/bin/bash

# 1. Crear directorio de pruebas y entrar en él
DIR_PRUEBAS="test_ordenacion"
mkdir -p "$DIR_PRUEBAS"
cd "$DIR_PRUEBAS" || exit

echo "Generando archivos de prueba en $DIR_PRUEBAS..."

# 2. Archivos para Probar Longitud (-a) y Nombres al revés (-b)
touch "a"                # Corto
touch "archivo_largo"    # Largo
touch "banana"           # Al revés termina en 'a'
touch "anana"            # Al revés termina en 'a'

# 3. Archivos para Probar Permisos/Grupos (-d)
# Creamos archivos con diferentes permisos del propietario (rwx)
touch "perm_700" && chmod 700 "perm_700" # Grupo 7 (rwx)
touch "perm_400" && chmod 400 "perm_400" # Grupo 4 (r--)
touch "perm_644" && chmod 644 "perm_644" # Grupo 6 (rw-)

# 4. Archivos para Probar Tamaños (-d)
dd if=/dev/zero of="grande" bs=1K count=10 2>/dev/null  # 10KB
dd if=/dev/zero of="pequeno" bs=1 count=10 2>/dev/null  # 10 Bytes

# 5. Archivos para Probar Meses de Acceso (-e)
# Usamos 'touch -a' para falsear la fecha de último acceso (formato AAAAMMDDHHMM)
touch -a -t 202301011200 "enero_archivo"
touch -a -t 202305201200 "mayo_archivo"
touch -a -t 202312251200 "diciembre_archivo"

# 6. Forzar creación de archivos para ver diferencias de Inodos (-c)
# (Los inodos los asigna el sistema automáticamente al crear)
for i in {1..5}; do touch "archivo_inodo_$i"; done

echo "¡Listo! Directorio '$DIR_PRUEBAS' preparado."
ls -l