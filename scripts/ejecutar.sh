#!/bin/bash

echo "Iniciando procesos en paralelo..."

(
    echo "Proceso 1 iniciado"

    if [ -f "Hola1.txt" ]; then
        echo "Hola1.txt ya existe, eliminando..."
        rm -f "Hola1.txt"
    fi

    sleep 2

    echo "Hola1" > "Hola1.txt"

    echo "Hola1.txt creado"
) &
PID1=$!

(
    echo "Proceso 2 iniciado"

    if [ -f "Hola2.txt" ]; then
        echo "Hola2.txt ya existe, eliminando..."
        rm -f "Hola2.txt"
    fi

    sleep 2

    echo "Hola2" > "Hola2.txt"

    echo "Hola2.txt creado"
) &
PID2=$!

echo "PID Proceso 1: $PID1"
echo "PID Proceso 2: $PID2"

wait "$PID1"
STATUS1=$?

wait "$PID2"
STATUS2=$?

echo "Finalizaron ambos procesos."

if [ "$STATUS1" -ne 0 ] || [ "$STATUS2" -ne 0 ]; then
    echo "Alguno de los procesos fallo."
    exit 1
fi

echo "Ambos procesos terminaron correctamente."

echo "Archivos generados:"
ls -l Hola1.txt Hola2.txt

echo "Contenido de Hola1.txt:"
cat Hola1.txt

echo "Contenido de Hola2.txt:"
cat Hola2.txt