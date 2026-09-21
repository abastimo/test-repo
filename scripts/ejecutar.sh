#!/bin/bash

log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

validar_nombre() {
    local nombre="$1"

    if [[ "$nombre" == *"/"* ]] || [[ "$nombre" == *"\\"* ]] || [[ "$nombre" == "." ]] || [[ "$nombre" == ".." ]]; then
        return 1
    fi

    return 0
}

if ! validar_nombre "$NOMBRE_ARCHIVO_1"; then
    echo "Nombre de archivo 1 invalido: $NOMBRE_ARCHIVO_1"
    exit 1
fi

if ! validar_nombre "$NOMBRE_ARCHIVO_2"; then
    echo "Nombre de archivo 2 invalido: $NOMBRE_ARCHIVO_2"
    exit 1
fi

log "Iniciando procesos en paralelo..."

log "Archivo 1: $NOMBRE_ARCHIVO_1"
log "Archivo 2: $NOMBRE_ARCHIVO_2"

(
    log "[Proceso 1] Inicio"

    if [ -f "$NOMBRE_ARCHIVO_1" ]; then
        log "[Proceso 1] $NOMBRE_ARCHIVO_1 existe. Eliminando..."
        rm -f -- "$NOMBRE_ARCHIVO_1"
    fi

    log "[Proceso 1] Etapa 1"
    sleep 2

    log "[Proceso 1] Escribiendo contenido..."
    printf '%s\n' "$CONTENIDO_ARCHIVO_1" > "$NOMBRE_ARCHIVO_1"

    sleep 2

    log "[Proceso 1] Archivo $NOMBRE_ARCHIVO_1 creado"
    log "[Proceso 1] Fin"
) &
PID1=$!

(
    log "[Proceso 2] Inicio"

    if [ -f "$NOMBRE_ARCHIVO_2" ]; then
        log "[Proceso 2] $NOMBRE_ARCHIVO_2 existe. Eliminando..."
        rm -f -- "$NOMBRE_ARCHIVO_2"
    fi

    log "[Proceso 2] Etapa 1"
    sleep 1

    log "[Proceso 2] Escribiendo contenido..."
    printf '%s\n' "$CONTENIDO_ARCHIVO_2" > "$NOMBRE_ARCHIVO_2"

    sleep 3

    log "[Proceso 2] Archivo $NOMBRE_ARCHIVO_2 creado"
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

log "Ambos procesos terminaron correctamente"

echo ""
echo "Resultado final:"

echo "Archivo 1: $NOMBRE_ARCHIVO_1"
cat -- "$NOMBRE_ARCHIVO_1"

echo ""

echo "Archivo 2: $NOMBRE_ARCHIVO_2"
cat -- "$NOMBRE_ARCHIVO_2"