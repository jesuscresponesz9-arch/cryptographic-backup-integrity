# 🔐 Sistema de Auditoría Criptográfica de Backup

## 🏛️ **Arquitectura Productor-Auditor con SHA-256 y GPG para Integridad Inquebrantable**

-----

## 🎯 **Descripción General**

Este proyecto implementa un sistema de respaldo diseñado para entornos donde la **integridad, autenticidad y confiabilidad** de los datos son requisitos obligatorios y no negociables.

En lugar de depender de un único *script* con permisos amplios (un enfoque frágil), el sistema adopta una **arquitectura de seguridad profesional basada en Separación de Responsabilidades y Mínimo Privilegio**:

  * **Producer** (`backup_seguro.sh`): Crea *backups* íntegros y firmados.
  * **Auditor** (`verificador_backup.sh`): Verifica cualquier *backup*, **sin tener permisos para modificarlo o confiar en su origen**.

Este modelo reproduce prácticas utilizadas en **banca, telecomunicaciones, infraestructuras críticas y cumplimiento normativo**.

-----

## 🚨 **Problema Crítico que Resuelve**

Los sistemas de *backup* tradicionales asumen confiabilidad. **En escenarios reales, esto es un riesgo:**

  * **Corrupción Silenciosa**: Fallos de *hardware* o *software* que alteran datos sin notificación.
  * **Manipulación Maliciosa**: Un atacante altera un *backup* o intenta que el sistema **re-firme un archivo comprometido**.
  * **Auto-Verificación Peligrosa**: Un *script* no puede auditarse a sí mismo de manera segura.

El resultado: la creencia de tener un *backup* válido se mantiene... **hasta que ocurre el desastre.**

-----

## ⚙️ **Arquitectura de la Solución: Separación de Privilegios**

El sistema se divide en **dos componentes con permisos totalmente segregados** a nivel de sistema operativo:

### 🏭 **1. Producer — `backup_seguro.sh`**

El Producer es el **generador de artefactos** con garantías criptográficas inherentes.

**Responsabilidad clave:** ***"El backup nace íntegro y auténtico."***

  * Genera un *backup* comprimido (`tar.gz`).
  * Calcula el **Hash SHA-256**.
  * Firma digitalmente el *backup* usando **GPG**.
  * Produce artefactos acompañados de **evidencia verificable**.

### 🕵️ **2. Auditor — `verificador_backup.sh`**

El Auditor es **imparcial y carece de la capacidad de escritura** (`w`) sobre los archivos de *backup*.

**Responsabilidad clave:** ***"Verifico la verdad, sin confianza ni capacidad de modificación."***

  * Verifica integridad mediante **SHA-256**.
  * Verifica autenticidad mediante **firma GPG** (`.asc`).
  * **Identifica al emisor real** y detecta suplantación.
  * Reporta corrupción o discrepancias.

-----

## 🔄 **Sinergia Operativa**

La fortaleza del sistema está en la **implementación de permisos Unix (rwx)**:

  * **El Producer tiene la `w` (escritura):** Puede crear los *backups*.
  * **El Auditor SOLO tiene la `r` (lectura):** Puede verificar los datos, pero no puede ser usado para **re-firmar un archivo malicioso**.

Este patrón ofrece: **Auditoría Imparcial** | **Detección de Manipulación** | **Trazabilidad Criptográfica**

-----

## 🚀 **Cómo Se Usa**

### **Crear un Backup**

```bash
./backup_seguro.sh
```

### **Verificar un Backup**

```bash
# Verificación básica (solo firma válida)
./verificador_backup.sh backup_2025-11-26_191454.tar.gz

# Verificación con emisor específico (recomendado)
./verificador_backup.sh backup_2025-11-26_191454.tar.gz jesus.cresponesz9@gmail.com
```

### **Salida del Verificador (Ejemplo)**

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

-----

## 🧪 **Pruebas de Estrés y Validación**

El diseño fue validado exitosamente contra los **tres ataques principales** que comprometen la integridad de datos:

| Ataque Simulado | Método de Detección | Resultado |
| :--- | :--- | :--- |
| **1. Corrupción de Datos** (Fallo Aleatorio) | Hash SHA256 inválido | ✅ **Detectado correctamente** |
| **2. Suplantación de Identidad** (Clave Adversaria) | Emisor GPG incorrecto | ✅ **Detectado correctamente** |
| **3. Manipulación Lógica** (Modificación + Recálculo) | Firma GPG y Permisos Unix | ✅ **Detectado correctamente** |

-----

## 🎯 **Casos de Uso Empresariales**

  * **Entornos Regulados**: Necesidad de auditoría reproducible (SOX/HIPAA).
  * **Infraestructura Crítica**: Detección temprana de corrupción en *storages*.
  * **Recuperación ante Desastres**: Validación de la integridad antes de cualquier restauración.
  * **Forensic Readiness**: Generación de evidencia criptográfica inmutable.

-----

## 🔧 **Implementación Técnica**

### **Flujo Principal:**

  * **Producer:** `tar` → `sha256sum` → `gpg` → `auto-validación` → `entrega`
  * **Auditor:** `sha256sum -c` → `gpg --verify` → `verificación_emisor` → `reporte`

### **Características de Seguridad:**

  * **Segregación de Permisos:** Evidencia en la estructura de permisos (`ls -l`).
  * **Criptografía:** SHA-256 (Hash) y GPG-RSA-2048 (Firma).
  * **Zero Trust:** El Auditor no asume la confiabilidad de ningún origen.

-----

## 📂 **Estructura del Proyecto**

```
/cryptographic-backup-system/
├── LICENSE
├── README.md
├── backup_seguro.sh
└── verificador_backup.sh
```

-----

## 📘 **Requisitos**

  * **GNU/Linux** (bash 4.0+)
  * **coreutils** (`tar`, `sha256sum`)
  * **gnupg2** (Configurado con las claves necesarias)
  * **Sistema de archivos** con soporte para permisos Unix.
