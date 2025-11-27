     1  #!/bin/bash
     2
     3  # ==============================================================================
     4  # SISTEMA DE BACKUP ENTERPRISE - JESÚS BRICEÑO
     5  # Ubuntu Server - Backup con Integridad SHA256 y Autenticidad GPG
     6  # ==============================================================================
     7
     8  # --- CONFIGURACIÓN (Actualizada con tus datos reales) ---
     9  ORIGEN="/home/linux/datos_criticos"           # TU directorio real
    10  DESTINO="/home/linux/backups_seguros"         # Donde guardar backups
    11  GPG_USER="jesus.cresponesz9@gmail.com"        # TU email GPG real
    12  FECHA=$(date +%Y-%m-%d_%H%M%S)
    13  NOMBRE_ARCHIVO="backup_$FECHA.tar.gz"
    14  RUTA_FINAL="$DESTINO/$NOMBRE_ARCHIVO"
    15  LOG_FILE="$DESTINO/backup_log.txt"
    16<
    17  # --- VERIFICACIONES INICIALES ---
    18  echo "=== INICIANDO VERIFICACIONES PRE-BACKUP ==="
    19
    20  # 1. Verificar que el origen existe
    21  if [ ! -d "$ORIGEN" ]; then
    22      echo "ERROR: Directorio origen $ORIGEN no existe"
    23      exit 1
    24  fi
    25
    26  # 2. Verificar que GPG está instalado y la clave existe
    27  if ! command -v gpg &> /dev/null; then
    28      echo "ERROR: GPG no está instalado"
    29      exit 1
    30  fi
    31
    32  if ! gpg --list-secret-keys "$GPG_USER" &> /dev/null; then
    33      echo "ERROR: Clave GPG para $GPG_USER no encontrada"
    34      echo "Claves disponibles:"
    35      gpg --list-secret-keys
    36      exit 1
    37  fi
    38
    39  # 3. Crear directorio destino si no existe
    40  mkdir -p "$DESTINO"
    41
    42  # --- FUNCIÓN DE LOGGING ---
    43  log() {
    44      local mensaje="[$(date +'%Y-%m-%d %H:%M:%S')] $1"
    45      echo "$mensaje"
    46      echo "$mensaje" >> "$LOG_FILE"
    47  }
    48
    49  # --- INICIO DEL PROCESO PRINCIPAL ---
    50  log "=== INICIANDO BACKUP SEGURO ==="
    51  log "Origen: $ORIGEN"
    52  log "Destino: $DESTINO"
    53  log "Usuario GPG: $GPG_USER"
    54
    55  # --- FASE 1: CREACIÓN DEL BACKUP ---
    56  log "FASE 1: Comprimiendo datos con tar..."
    57  tar -czf "$RUTA_FINAL" -C "$(dirname "$ORIGEN")" "$(basename "$ORIGEN")" 2>/dev/null
    58
    59  if [ $? -eq 0 ]; then
    60      log "✅ Backup comprimido: $NOMBRE_ARCHIVO"
    61      TAMANO=$(du -h "$RUTA_FINAL" | cut -f1)
    62      log "📊 Tamaño del backup: $TAMANO"
    63  else
    64      log "❌ ERROR: Falló la compresión con tar"
    65      exit 1
    66  fi
    67
    68  # --- FASE 2: INTEGRIDAD (Hash SHA256) ---
    69  log "FASE 2: Generando huella digital SHA256..."
    70  sha256sum "$RUTA_FINAL" > "$RUTA_FINAL.sha256"
    71
    72  if [ $? -eq 0 ]; then
    73      log "✅ Hash SHA256 generado: $NOMBRE_ARCHIVO.sha256"
    74      HASH_CORTO=$(cut -d' ' -f1 "$RUTA_FINAL.sha256" | head -c 10)
    75      log "🔢 Hash (abreviado): ${HASH_CORTO}..."
    76  else
    77      log "❌ ERROR: No se pudo generar el hash SHA256"
    78      exit 1
    79  fi
    80
    81  # --- FASE 3: AUTENTICIDAD (Firma GPG) ---
    82  log "FASE 3: Firmando digitalmente con GPG..."
    83  gpg --batch --yes --detach-sign --armor \
    84      --local-user "$GPG_USER" \
    85      --output "$RUTA_FINAL.asc" \
    86      "$RUTA_FINAL"
    87
    88  if [ $? -eq 0 ]; then
    89      log "✅ Firma digital creada: $NOMBRE_ARCHIVO.asc"
    90  else
    91      log "❌ ERROR: No se pudo firmar el archivo"
    92      exit 1
    93  fi
    94
    95  # --- FASE 4: VERIFICACIÓN AUTOMÁTICA ---
    96  log "FASE 4: Ejecutando verificación de seguridad..."
    97
    98  log "Verificando integridad SHA256..."
    99  VERIF_HASH=$(sha256sum -c "$RUTA_FINAL.sha256" 2>&1)
   100
   101  log "Verificando firma GPG..."
   102  VERIF_FIRMA=$(gpg --verify "$RUTA_FINAL.asc" "$RUTA_FINAL" 2>&1)
   103
   104  # --- EVALUACIÓN FINAL ---
   105  if [[ "$VERIF_HASH" == *"OK"* ]] && [[ "$VERIF_FIRMA" == *"Good signature"* ]]; then
   106      log "🎉 VERIFICACIÓN EXITOSA - Backup seguro y confiable"
   107      log "📁 Archivos creados:"
   108      log "   💾 Datos: $NOMBRE_ARCHIVO"
   109      log "   🔢 Integridad: $NOMBRE_ARCHIVO.sha256"
   110      log "   📜 Autenticidad: $NOMBRE_ARCHIVO.asc"
   111
   112      # Información para auditoría
   113      log "📋 Resumen para auditoría:"
   114      log "   - Origen: $ORIGEN"
   115      log "   - Tamaño: $TAMANO"
   116      log "   - Timestamp: $FECHA"
   117      log "   - Usuario: $(whoami)"
   118      log "   - Servidor: $(hostname)"
   119  else
   120      log "🚨 ALERTA CRÍTICA: Verificación falló"
   121      log "🔍 Detalles verificación Hash: $VERIF_HASH"
   122      log "🔍 Detalles verificación Firma: $VERIF_FIRMA"
   123
   124      # Medida de seguridad
   125      log "🛡️ Eliminando backup no confiable..."
   126      rm -f "$RUTA_FINAL" "$RUTA_FINAL.sha256" "$RUTA_FINAL.asc"
   127      exit 1
   128  fi
   129
   130  log "=== BACKUP FINALIZADO EXITOSAMENTE ==="
   131  exit 0
