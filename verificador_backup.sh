  1  #!/bin/bash
     2
     3  # ==============================================================================
     4  # VERIFICADOR DE BACKUP - CON DETECCIÓN DE EMISOR
     5  # ==============================================================================
     6
     7  BACKUP="$1"
     8  EMISOR_ESPERADO="jesus.cresponesz9@gmail.com"
     9
    10  # --- VERIFICACIONES INICIALES ---
    11  if [ -z "$BACKUP" ]; then
    12      echo "❌ Uso: $0 <archivo_backup.tar.gz>"
    13      exit 1
    14  fi
    15
    16  if [ ! -f "$BACKUP" ]; then
    17      echo "❌ ERROR: Backup $BACKUP no existe"
    18      exit 1
    19  fi
    20
    21  echo "=== VERIFICANDO BACKUP: $(basename "$BACKUP") ==="
    22
    23  # --- VERIFICACIÓN SHA256 ---
    24  echo "1. 🔍 Verificando INTEGRIDAD (SHA256)..."
    25  if [ -f "${BACKUP}.sha256" ]; then
    26      if sha256sum -c "${BACKUP}.sha256" > /dev/null 2>&1; then
    27          echo "   ✅ INTEGRIDAD CONFIRMADA: Archivo no corrupto"
    28          RESULTADO_HASH=0
    29      else
    30          echo "   ❌ INTEGRIDAD FALLIDA: Archivo corrupto o modificado"
    31          RESULTADO_HASH=1
    32      fi
    33  else
    34      echo "   ❌ No existe archivo .sha256"
    35      RESULTADO_HASH=1
    36  fi
    37
    38  # --- VERIFICACIÓN GPG CON EMISOR ---
    39  echo "2. 🔐 Verificando AUTENTICIDAD (GPG)..."
    40  if [ -f "${BACKUP}.asc" ]; then
    41      VERIF_FIRMA=$(gpg --verify "${BACKUP}.asc" "$BACKUP" 2>&1)
    42
    43      # Extraer información de la firma
    44      FIRMA_VALIDA=$(echo "$VERIF_FIRMA" | grep -c "Good signature")
    45      EMISOR_REAL=$(echo "$VERIF_FIRMA" | grep "issuer" | cut -d'"' -f2 2>/dev/null)
    46
    47      if [ "$FIRMA_VALIDA" -eq 1 ] && [ "$EMISOR_REAL" = "$EMISOR_ESPERADO" ]; then
    48          echo "   ✅ AUTENTICIDAD CONFIRMADA: Firma válida de $EMISOR_ESPERADO"
    49          RESULTADO_FIRMA=0
    50      else
    51          echo "   ❌ AUTENTICIDAD FALLIDA:"
    52          echo "      - Firma válida: $([ "$FIRMA_VALIDA" -eq 1 ] && echo "Sí" || echo "No")"
    53          echo "      - Emisor esperado: $EMISOR_ESPERADO"
    54          echo "      - Emisor real: $EMISOR_REAL"
    55          RESULTADO_FIRMA=1
    56      fi
    57  else
    58      echo "   ❌ No existe archivo .asc"
    59      RESULTADO_FIRMA=1
    60  fi
    61
    62  # --- EVALUACIÓN FINAL ---
    63  echo ""
    64  echo "=== 📊 RESULTADO FINAL ==="
    65  if [ $RESULTADO_HASH -eq 0 ] && [ $RESULTADO_FIRMA -eq 0 ]; then
    66      echo "🎉 BACKUP VERIFICADO: Íntegro y auténtico"
    67      echo "   ✅ Integridad: Confirmada"
    68      echo "   ✅ Autenticidad: Confirmada"
    69      exit 0
    70  else
    71      echo "🚨 BACKUP NO CONFIABLE"
    72      echo "   ❌ Integridad: $([ $RESULTADO_HASH -eq 0 ] && echo "OK" || echo "FALLÓ")"
    73      echo "   ❌ Autenticidad: $([ $RESULTADO_FIRMA -eq 0 ] && echo "OK" || echo "FALLÓ")"
    74      exit 1
    75  fi
    76
