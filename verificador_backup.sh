   1  #!/bin/bash
     2
     3  # ==============================================================================
     4  # VERIFICADOR ENTERPRISE - BACKUP VERIFICATION SYSTEM
     5  # ==============================================================================
     6
     7  BACKUP="$1"
     8  EMISOR_ESPERADO="${2:-}"
     9
    10  # --- FUNCIÓN PRINCIPAL DE VERIFICACIÓN ---
    11  verify_backup() {
    12      local backup="$1"
    13      local expected_issuer="$2"
    14
    15      echo "=== VERIFICANDO BACKUP: $(basename "$backup") ==="
    16
    17      # 1. Verificar integridad SHA256
    18      echo "1. 🔍 Verificando INTEGRIDAD (SHA256)..."
    19      if [ -f "${backup}.sha256" ]; then
    20          if sha256sum -c "${backup}.sha256" > /dev/null 2>&1; then
    21              echo "   ✅ INTEGRIDAD CONFIRMADA: Archivo no corrupto"
    22          else
    23              echo "   ❌ INTEGRIDAD FALLIDA: Archivo corrupto o modificado"
    24              return 1
    25          fi
    26      else
    27          echo "   ❌ No existe archivo .sha256"
    28          return 1
    29      fi
    30
    31      # 2. Verificar firma GPG
    32      echo "2. 🔐 Verificando AUTENTICIDAD (GPG)..."
    33      if [ -f "${backup}.asc" ]; then
    34          local verification_output
    35          verification_output=$(gpg --verify "${backup}.asc" "$backup" 2>&1)
    36
    37          # Verificar firma válida
    38          if echo "$verification_output" | grep -q "Good signature"; then
    39              echo "   ✅ FIRMA VÁLIDA: Firma criptográfica correcta"
    40          else
    41              echo "   ❌ FIRMA INVÁLIDA: Firma criptográfica falló"
    42              return 2
    43          fi
    44
    45          # 3. Verificar emisor si se especificó
    46          if [[ -n "$expected_issuer" ]]; then
    47              local actual_issuer=$(echo "$verification_output" | grep "issuer" | sed -n 's/.*"\([^"]*\)".*/\1/p')
    48              if [[ "$actual_issuer" == "$expected_issuer" ]]; then
    49                  echo "   ✅ EMISOR VERIFICADO: $actual_issuer"
    50              else
    51                  echo "   ❌ EMISOR INVALIDO:"
    52                  echo "      - Esperado: $expected_issuer"
    53                  echo "      - Real: $actual_issuer"
    54                  return 3
    55              fi
    56          else
    57              local actual_issuer=$(echo "$verification_output" | grep "issuer" | sed -n 's/.*"\([^"]*\)".*/\1/p')
    58              echo "   📧 EMISOR DETECTADO: $actual_issuer (no verificado)"
    59          fi
    60      else
    61          echo "   ❌ No existe archivo .asc"
    62          return 2
    63      fi
    64
    65      # --- EVALUACIÓN FINAL ---
    66      echo ""
    67      echo "=== 📊 RESULTADO FINAL ==="
    68      echo "🎉 BACKUP VERIFICADO: Íntegro y auténtico"
    69      return 0
    70  }
    71
    72  # --- EJECUCIÓN PRINCIPAL ---
    73  if [ -z "$BACKUP" ]; then
    74      echo "❌ Uso: $0 <archivo_backup> [emisor_esperado]"
    75      echo "   Ejemplos:"
    76      echo "   $0 backup.tar.gz                      # Verifica solo firma válida"
    77      echo "   $0 backup.tar.gz user@domain.com      # Verifica firma y emisor"
    78      exit 1
    79  fi
    80
    81  if [ ! -f "$BACKUP" ]; then
    82      echo "❌ ERROR: Backup $BACKUP no existe"
    83      exit 1
    84  fi
    85
    86  verify_backup "$BACKUP" "$EMISOR_ESPERADO"
    87  exit $?
