#!/bin/bash

echo "Iniciando procesos en paralelo..."

(
    echo "[Proceso 1] Inicio"

    if [ -f "Hola1.txt" ]; then
        echo "[Proceso 1] Eliminando archivo anterior"
        rm -f "Hola1.txt"
    fi

    echo "[Proceso 1] Etapa 1"
    sleep 2

    echo "[Proceso 1] Etapa 2"
    sleep 3

    echo "Hola1 generado en $(date)" > "Hola1.txt"

    echo "[Proceso 1] Fin"
) &
PID1=$!

(
    echo "[Proceso 2] Inicio"

    if [ -f "Hola2.txt" ]; then
        echo "[Proceso 2] Eliminando archivo anterior"
        rm -f "Hola2.txt"
    fi

    echo "[Proceso 2] Etapa 1"
    sleep 1

    echo "[Proceso 2] Etapa 2"
    sleep 4

    echo "Hola2 generado en $(date)" > "Hola2.txt"

    echo "[Proceso 2] Fin"
) &
PID2=$!

echo "PID Proceso 1: $PID1"
echo "PID Proceso 2: $PID2"

wait "$PID1"
STATUS1=$?

wait "$PID2"
STATUS2=$?

echo "Ambos procesos terminaron"

if [ "$STATUS1" -ne 0 ] || [ "$STATUS2" -ne 0 ]; then
    echo "Alguno de los procesos fallo"
    exit 1
fi

echo "Resultado final:"
cat Hola1.txt
cat Hola2.txt