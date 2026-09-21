#!/bin/bash

echo "Iniciando ejecuciones en paralelo..."

bash scripts/hola1.txt &
PID1=$!

bash scripts/hola2.txt &
PID2=$!

echo "PID Hola1: $PID1"
echo "PID Hola2: $PID2"

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