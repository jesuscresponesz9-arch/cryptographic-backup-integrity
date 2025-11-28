🔐 **Cryptographic Backup Verification System**  
**Arquitectura Producer/Auditor con SHA-256 y GPG para integridad verificable en sistemas críticos**

---

## 🧩 **Descripción General**

Este proyecto implementa un sistema de respaldo diseñado para entornos donde la **integridad, autenticidad y confiabilidad** de los datos son requisitos obligatorios.

En lugar de utilizar un único script que crea y verifica sus propios archivos —un enfoque débil y propenso a errores— el sistema adopta una **arquitectura profesional basada en separación de responsabilidades**:

- **Producer** (`backup_seguro.sh`): crea backups íntegros y firmados
- **Auditor** (`verificador_backup.sh`): verifica cualquier backup, sin confiar en su origen

Este modelo reproduce prácticas utilizadas en sectores como **banca, telecomunicaciones, infraestructuras críticas y cumplimiento normativo**.

---

## 🚨 **Problema que Resuelve**

Los sistemas de backup tradicionales asumen que:
- El entorno que genera el backup es confiable
- El archivo no será manipulado  
- El proceso de verificación puede ser realizado por la misma herramienta que lo creó

En **escenarios reales**, estas suposiciones fallan:
- **Corrupción silenciosa**: cambios mínimos pasan desapercibidos
- **Manipulación maliciosa**: un atacante altera un backup sin ser detectado
- **Auto-verificación peligrosa**: un script no puede auditarse a sí mismo

El resultado: los equipos creen tener un backup válido… **hasta que lo necesitan**.

---

## 🏛️ **Arquitectura de la Solución**

El sistema se divide en **dos componentes totalmente independientes**:

### 🔐 **1. Producer — `backup_seguro.sh`**
El Producer es responsable de crear los respaldos con **garantías criptográficas inherentes**.

**Funciones principales:**
- Genera un backup comprimido (`tar.gz`)
- Calcula un hash **SHA-256** 
- Firma digitalmente el backup usando **GPG**
- **Verifica su propia salida** antes de entregarla
- Produce artefactos acompañados de **evidencia verificable**

**Responsabilidad clave:** *"El backup nace íntegro y auténtico."*

### 🔍 **2. Auditor — `verificador_backup.sh`** 
El Auditor es **totalmente independiente** del Producer y valida **cualquier respaldo**.

**Funciones principales:**
- Verifica integridad mediante **SHA-256**
- Verifica autenticidad mediante **firma GPG** (`.asc`)
- **Identifica al emisor real** y detecta suplantación
- Reporta corrupción, manipulación o discrepancias
- **No modifica nada**: auditoría pura

**Responsabilidad clave:** *"Verifico, sin confiar en ningún origen."*

---

## 🔄 **Sinergia Operativa**

La fortaleza del sistema está en la **combinación**:
- **Producer**: fabrica respaldos confiables
- **Auditor**: valida respaldos en **cualquier contexto**

Este patrón ofrece:
- **Auditoría imparcial**
- **Evidencia criptográfica independiente**
- **Detección de manipulación maliciosa**
- **Trazabilidad reproducible**
- **Confiabilidad** incluso en ambientes comprometidos

Es el mismo enfoque utilizado en **seguridad industrial** y procesos de integridad digital.

---

## 🚀 **Cómo Se Usa**

### **Crear un Backup**
```bash
./backup_seguro.sh
```

### **Verificar un Backup**
```bash
# Verificación básica (solo firma válida)
./verificador_backup.sh backup_2025-11-26_191454.tar.gz

# Verificación con emisor específico  
./verificador_backup.sh backup_2025-11-26_191454.tar.gz jesus.cresponesz9@gmail.com
```

### **Salida del Verificador**
```
=== VERIFICANDO BACKUP: backup_2025-11-26_191454.tar.gz ===
1. 🔍 Verificando INTEGRIDAD (SHA256)...
   ✅ INTEGRIDAD CONFIRMADA: Archivo no corrupto
2. 🔐 Verificando AUTENTICIDAD (GPG)...
   ✅ FIRMA VÁLIDA: Firma criptográfica correcta
   ✅ EMISOR VERIFICADO: jesus.cresponesz9@gmail.com

=== 📊 RESULTADO FINAL ===
🎉 BACKUP VERIFICADO: Íntegro y auténtico
```

---

## 🧪 **Pruebas Realizadas**

Se validaron los **tres ataques principales** que afectan a sistemas reales:

### **1. Corrupción de Datos**
```bash
echo "DATOS_CORRUPTOS" >> backup.tar.gz
```
**Resultado:** ✅ **Detectado correctamente** - Hash SHA256 inválido

### **2. Suplantación de Identidad**
```bash
# Firma con clave adversaria
gpg --local-user "hacker@evil.com" --detach-sign backup.tar.gz
```
**Resultado:** ✅ **Detectado correctamente** - Emisor incorrecto identificado

### **3. Ataque Man-in-the-Middle**
```bash
# Modificación + recálculo de hash (sin firma válida)
```
**Resultado:** ✅ **Detectado correctamente** - Firma GPG inválida

La arquitectura demuestra capacidad para identificar:
- **Corrupción accidental**
- **Manipulación maliciosa** 
- **Suplantación criptográfica**

---

## 📂 **Salidas del Sistema**

### **El Producer genera:**
- `backup_FECHA.tar.gz` (datos comprimidos)
- `backup_FECHA.tar.gz.sha256` (hash de integridad)
- `backup_FECHA.tar.gz.asc` (firma GPG)
- `backup_log.txt` (logs con trazabilidad completa)

### **El Auditor proporciona:**
- **Reporte de integridad** (SHA256)
- **Validación del emisor** (GPG issuer)
- **Resultado final claro** (OK/FAIL)
- **Diagnóstico específico** de fallos

---

## 🎯 **Casos de Uso**

- **Entornos regulados**: auditoría reproducible para SOX/HIPAA
- **Infraestructura crítica**: detección temprana de corrupción
- **Recuperación ante desastres**: validar antes de restaurar
- **Equipos distribuidos**: verificar backups de múltiples administradores
- **Cadenas de suministro digital**: autenticidad garantizada
- **Forensic readiness**: evidencia criptográfica para investigaciones

---

## 🔧 **Implementación Técnica**

### **Flujo del Producer:**
```bash
tar → sha256sum → gpg → auto-validación → entrega
```

### **Flujo del Auditor:**
```bash
sha256sum -c → gpg --verify → verificación_emisor → reporte
```

### **Características de Seguridad:**
- **SHA-256**: Resistencia a colisiones (2¹²⁸ operaciones)
- **GPG-RSA-2048**: Resistencia (2¹¹² operaciones)
- **Verificación en tiempo real**: sub-segundos
- **Zero trust**: No asume confianza en el origen

---

## 📦 **Estructura del Proyecto**
```
~/scripts/
├── backup_seguro.sh          # Producer
├── verificador_backup.sh     # Auditor
└── README.md

```
---

## 📘 **Requisitos**

- **GNU/Linux** (Debian, Ubuntu, RHEL, etc.)
- **bash** 4.0+
- **coreutils**: tar, sha256sum
- **gnupg2** correctamente configurado
- **Sistema de archivos** con soporte para permisos Unix

---

## 📄 **Licencia**
**MIT License** - Libre uso, modificación y distribución para fines comerciales y personales.
