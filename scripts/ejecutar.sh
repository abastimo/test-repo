#!/bin/bash

# ============================================================
# Script: ejecutar.sh
# Descripción:
#   Ejecuta dos procesos en paralelo.
#   Cada proceso:
#     - Valida el nombre de archivo recibido.
#     - Elimina el archivo si ya existe.
#     - Crea nuevamente el archivo.
#     - Escribe el contenido recibido mediante variables
#       de entorno.
#
# Variables de entorno esperadas:
#   NOMBRE_ARCHIVO_1
#   CONTENIDO_ARCHIVO_1
#   NOMBRE_ARCHIVO_2
#   CONTENIDO_ARCHIVO_2
#
# El script utiliza procesos en background (&), captura sus PID
# y espera su finalización mediante wait.
# ============================================================


# ------------------------------------------------------------
# Función: log
# Descripción:
#   Imprime mensajes en consola incluyendo un timestamp.
#
# Ejemplo:
#   [09:30:15] [Proceso 1] Inicio
# ------------------------------------------------------------
log() {
    echo "[$(date '+%H:%M:%S')] $1"
}


# ------------------------------------------------------------
# Función: validar_nombre
# Parámetro:
#   $1 -> Nombre del archivo a validar.
#
# Descripción:
#   Valida que el nombre recibido sea un nombre simple de archivo
#   y no contenga rutas o referencias a directorios.
#
# No permite:
#   /
#   \
#   .
#   ..
#
# Retorno:
#   0 -> Nombre válido.
#   1 -> Nombre inválido.
# ------------------------------------------------------------
validar_nombre() {
    local nombre="$1"

    if [[ "$nombre" == *"/"* ]] || \
       [[ "$nombre" == *"\\"* ]] || \
       [[ "$nombre" == "." ]] || \
       [[ "$nombre" == ".." ]]; then
        return 1
    fi

    return 0
}


# ------------------------------------------------------------
# Validación del nombre del primer archivo.
# Si el nombre no es válido, el script finaliza con código 1.
# ------------------------------------------------------------
if ! validar_nombre "$NOMBRE_ARCHIVO_1"; then
    echo "Nombre de archivo 1 invalido: $NOMBRE_ARCHIVO_1"
    exit 1
fi


# ------------------------------------------------------------
# Validación del nombre del segundo archivo.
# ------------------------------------------------------------
if ! validar_nombre "$NOMBRE_ARCHIVO_2"; then
    echo "Nombre de archivo 2 invalido: $NOMBRE_ARCHIVO_2"
    exit 1
fi


# ------------------------------------------------------------
# Inicio general del procesamiento.
# ------------------------------------------------------------
log "Iniciando procesos en paralelo..."

log "Archivo 1: $NOMBRE_ARCHIVO_1"
log "Archivo 2: $NOMBRE_ARCHIVO_2"


# ============================================================
# PROCESO 1
#
# Los paréntesis crean una subshell.
# El símbolo '&' al final hace que esta subshell se ejecute
# en background, permitiendo continuar inmediatamente con
# el Proceso 2.
# ============================================================
(
    log "[Proceso 1] Inicio"

    # Verifica si el archivo ya existe.
    if [ -f "$NOMBRE_ARCHIVO_1" ]; then
        log "[Proceso 1] $NOMBRE_ARCHIVO_1 existe. Eliminando..."

        # Elimina el archivo existente.
        # '--' evita que un nombre que comience con '-' sea
        # interpretado como una opción del comando rm.
        rm -f -- "$NOMBRE_ARCHIVO_1"
    fi

    log "[Proceso 1] Etapa 1"

    # Espera artificial utilizada para visualizar mejor
    # la ejecución paralela en los logs.
    sleep 2

    log "[Proceso 1] Escribiendo contenido..."

    # Crea el archivo y escribe el contenido recibido.
    # '>' reemplaza completamente el contenido del archivo.
    printf '%s\n' "$CONTENIDO_ARCHIVO_1" > "$NOMBRE_ARCHIVO_1"

    # Segunda espera artificial para evidenciar el paralelismo.
    sleep 2

    log "[Proceso 1] Archivo $NOMBRE_ARCHIVO_1 creado"
    log "[Proceso 1] Fin"

) &

# $! contiene el PID del último proceso ejecutado en background.
# Se guarda para poder esperar posteriormente su finalización.
PID1=$!


# ============================================================
# PROCESO 2
#
# Se ejecuta de manera independiente y simultánea al Proceso 1.
# ============================================================
(
    log "[Proceso 2] Inicio"

    # Verifica si el segundo archivo ya existe.
    if [ -f "$NOMBRE_ARCHIVO_2" ]; then
        log "[Proceso 2] $NOMBRE_ARCHIVO_2 existe. Eliminando..."
        rm -f -- "$NOMBRE_ARCHIVO_2"
    fi

    log "[Proceso 2] Etapa 1"

    # Tiempo diferente al Proceso 1 para demostrar que ambos
    # procesos avanzan de forma independiente.
    sleep 1

    log "[Proceso 2] Escribiendo contenido..."

    # Crea el segundo archivo con el contenido recibido.
    printf '%s\n' "$CONTENIDO_ARCHIVO_2" > "$NOMBRE_ARCHIVO_2"

    sleep 3

    log "[Proceso 2] Archivo $NOMBRE_ARCHIVO_2 creado"
    log "[Proceso 2] Fin"

) &

# Guarda el PID del segundo proceso en background.
PID2=$!


# ------------------------------------------------------------
# Muestra los PID de ambos procesos.
# Esto permite identificar que son procesos independientes.
# ------------------------------------------------------------
log "PID Proceso 1: $PID1"
log "PID Proceso 2: $PID2"


# ------------------------------------------------------------
# Espera a que termine el Proceso 1.
#
# wait devuelve el código de salida del proceso esperado.
# $? almacena el código de salida del último comando ejecutado.
#
# Código 0     -> ejecución correcta.
# Código != 0  -> ocurrió algún error.
# ------------------------------------------------------------
wait "$PID1"
STATUS1=$?


# ------------------------------------------------------------
# Espera a que termine el Proceso 2.
# ------------------------------------------------------------
wait "$PID2"
STATUS2=$?


# ------------------------------------------------------------
# En este punto ambos procesos ya finalizaron.
# ------------------------------------------------------------
log "Ambos procesos terminaron"


# ------------------------------------------------------------
# Validación de códigos de salida.
#
# Si cualquiera de los dos procesos devuelve un código distinto
# de cero, se considera que la ejecución general falló.
# ------------------------------------------------------------
if [ "$STATUS1" -ne 0 ] || [ "$STATUS2" -ne 0 ]; then
    log "Alguno de los procesos fallo"
    exit 1
fi


log "Ambos procesos terminaron correctamente"


# ============================================================
# RESULTADO FINAL
#
# Muestra los nombres y contenidos de ambos archivos generados.
# ============================================================
echo ""
echo "Resultado final:"

echo "Archivo 1: $NOMBRE_ARCHIVO_1"
cat -- "$NOMBRE_ARCHIVO_1"

echo ""

echo "Archivo 2: $NOMBRE_ARCHIVO_2"
cat -- "$NOMBRE_ARCHIVO_2"