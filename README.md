# Cryptographic Backup Integrity

**Arquitectura Producer/Auditor con SHA-256 y GPG para integridad verificable en sistemas críticos**

## 🧩 Descripción General

Este proyecto implementa un sistema de respaldo diseñado para entornos donde la integridad, autenticidad y confiabilidad de los datos son requisitos obligatorios.

En lugar de utilizar un único script que crea y verifica sus propios archivos —un enfoque débil y propenso a errores— el sistema adopta una arquitectura profesional basada en separación de responsabilidades:

- **Producer** (`backup_seguro.sh`): crea backups íntegros y firmados.
- **Auditor** (`verificador_backup.sh`): verifica cualquier backup, sin confiar en su origen.

Este modelo reproduce prácticas utilizadas en sectores como banca, telecomunicaciones, infraestructuras críticas y cumplimiento normativo.

## 🚨 Problema que Resuelve

Los sistemas de backup tradicionales asumen que:
- el entorno que genera el backup es confiable,
- el archivo no será manipulado,  
- el proceso de verificación puede ser realizado por la misma herramienta que lo creó.

En escenarios reales, estas suposiciones fallan:
- **Corrupción silenciosa**: cambios mínimos pasan desapercibidos.
- **Manipulación maliciosa**: un atacante altera un backup sin ser detectado.
- **Auto-verificación peligrosa**: un script no puede auditarse a sí mismo.

El resultado: los equipos creen tener un backup válido… hasta que lo necesitan.

## 🏛️ Arquitectura de la Solución

El sistema se divide en dos componentes totalmente independientes:

### 🔐 1. Producer — `backup_seguro.sh`

El Producer es responsable de crear los respaldos con garantías criptográficas inherentes.

**Funciones principales:**
- Genera un backup comprimido (tar.gz)
- Calcula un hash SHA-256
- Firma digitalmente el backup usando GPG
- Verifica su propia salida antes de entregarla
- Produce artefactos acompañados de evidencia verificable

**Responsabilidad clave:** *"El backup nace íntegro y auténtico."*

### 🔍 2. Auditor — `verificador_backup.sh`

El Auditor es totalmente independiente del Producer y valida cualquier respaldo.

**Funciones principales:**
- Verifica integridad mediante SHA-256
- Verifica autenticidad mediante firma GPG (.asc)
- Identifica al emisor real y detecta suplantación
- Reporta corrupción, manipulación o discrepancias
- No modifica nada: auditoría pura

**Responsabilidad clave:** *"Verifico, sin confiar en ningún origen."*

## 🔄 Sinergia Operativa

La fortaleza del sistema está en la combinación:
- **Producer**: fabrica respaldos confiables.
- **Auditor**: valida respaldos en cualquier contexto.

Este patrón ofrece:
- Auditoría imparcial.
- Evidencia criptográfica independiente.
- Detección de manipulación maliciosa.
- Trazabilidad reproducible.
- Confiabilidad incluso en ambientes comprometidos.

Es el mismo enfoque utilizado en seguridad industrial y procesos de integridad digital.

## 🚀 Cómo Se Usa

### Crear un Backup
```bash
./backup_seguro.sh /ruta/a/tus/datos
```

### Verificar un Backup  
```bash
./verificador_backup.sh backup_2024-01-01_120000.tar.gz
```

### Salida del Verificador
```
=== VERIFICACIÓN CRIPTOGRÁFICA ===
✅ INTEGRIDAD: SHA-256 válido
✅ AUTENTICIDAD: Firma GPG verificada
=== RESULTADO: BACKUP CONFIABLE ===
```

## 🧪 Pruebas Realizadas

Se validaron los tres ataques principales que afectan a sistemas reales:

1. **Corrupción de datos**
   - Alteración mínima → el hash falla.
   - *Resultado: Detectado correctamente.*

2. **Manipulación sin firma**
   - Modificar archivo sin modificar firma → Auditor rechaza.
   - *Resultado: Detectado correctamente.*

3. **Firma válida pero de emisor incorrecto**
   - Firma de un atacante con GPG propio → autenticidad fallida.
   - *Resultado: Detectado correctamente.*

La arquitectura demuestra capacidad para identificar:
- corrupción accidental,
- manipulación maliciosa, 
- suplantación criptográfica.

## 📂 Salidas del Sistema

**El Producer genera:**
- `backup.tar.gz`
- `backup.tar.gz.sha256`
- `backup.tar.gz.asc` (firma GPG)
- Logs con trazabilidad completa

**El Auditor proporciona:**
- Reporte de integridad
- Validación del emisor
- Resultado final claro (OK/FAIL)

## 🎯 Casos de Uso

- Entornos regulados: auditoría reproducible.
- Infraestructura crítica: detección temprana de corrupción.
- Recuperación ante desastres: validar antes de restaurar.
- Equipos distribuidos: verificar backups de terceros.
- Cadenas de suministro digital: autenticidad garantizada.

## 📘 Requisitos

- GNU/Linux (Debian, Ubuntu, etc.)
- bash
- tar, sha256sum
- gpg correctamente configurado

---

**📄 Licencia:** MIT
