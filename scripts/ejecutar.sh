#!/bin/bash

log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

log "Iniciando procesos en paralelo..."

(
    log "[Proceso 1] Inicio"

    if [ -f "Hola1.txt" ]; then
        log "[Proceso 1] Eliminando archivo anterior"
        rm -f "Hola1.txt"
    fi

    log "[Proceso 1] Etapa 1"
    sleep 2

    log "[Proceso 1] Etapa 2"
    sleep 3

    echo "Hola1 generado en $(date)" > "Hola1.txt"

    log "[Proceso 1] Fin"
) &
PID1=$!

(
    log "[Proceso 2] Inicio"

    if [ -f "Hola2.txt" ]; then
        log "[Proceso 2] Eliminando archivo anterior"
        rm -f "Hola2.txt"
    fi

    log "[Proceso 2] Etapa 1"
    sleep 1

    log "[Proceso 2] Etapa 2"
    sleep 4

    echo "Hola2 generado en $(date)" > "Hola2.txt"

    log "[Proceso 2] Fin"
) &
PID2=$!

log "PID Proceso 1: $PID1"
log "PID Proceso 2: $PID2"

wait "$PID1"
STATUS1=$?

wait "$PID2"
STATUS2=$?

log "Ambos procesos terminaron"

if [ "$STATUS1" -ne 0 ] || [ "$STATUS2" -ne 0 ]; then
    log "Alguno de los procesos fallo"
    exit 1
fi

log "Resultado final:"

cat Hola1.txt
cat Hola2.txt