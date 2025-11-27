# Sistema de Integridad Criptográfica para Backups 🔐

## Descripción
Implementación de un **sistema de verificación criptográfica independiente** usando **SHA-256 y GPG para garantizar autenticidad e integridad de backups** en entornos de alta seguridad.

## Características Principales 🛡️

- **Arquitectura Producer/Auditor** 🏗️ - Separación completa entre generación y verificación
- **Verificación criptográfica** 🔑 - Hash SHA-256 + firmas GPG para integridad y autenticidad  
- **Auditoría independiente** 👁️ - El verificador opera sin dependencias del sistema productor
- **Detección de manipulación** 🚨 - Identifica corrupción y falsificación de backups
- **Zero-trust verification** 🔒 - No confía en el entorno de origen

---

### Componentes del Sistema ⚙️

**backup_seguro.sh** 📦 - Módulo Productor
- Generación de backups comprimidos
- Cálculo de hash SHA-256
- Firma digital GPG
- Validación inicial post-generación

**verificador_backup.sh** 🔍 - Módulo Auditor  
- Verificación independiente de integridad
- Validación de firmas digitales
- Confirmación de emisor autorizado
- Reporte de estado de confiabilidad

---

### Casos de Verificación ✅❌

| Escenario | Comportamiento | Resultado |
|-----------|----------------|-----------|
| Backup normal | Hash válido + Firma correcta + Emisor autorizado | ✅ CONFIABLE |
| Datos corruptos | Hash no coincide | ❌ NO CONFIABLE |
| Firma falsificada | Firma válida pero emisor incorrecto | ❌ NO CONFIABLE |

---

### Uso del Sistema 🚀

```bash
# Generar backup con verificación criptográfica
./backup_seguro.sh /ruta/datos/criticos

# Verificar integridad y autenticidad
./verificador_backup.sh backup_2024-01-01_120000.tar.gz
```

**Licencia:** MIT 📄
