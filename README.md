# Cryptographic Backup Integrity

**Sistema de Backup con Verificación Criptográfica Independiente**  
*Arquitectura Producer/Auditor con SHA-256 y GPG para garantizar integridad en entornos de alta seguridad*

---

## 🚨 Problema que Resuelve

La mayoría de los sistemas de backup fallan en un punto crítico: **confían en que el entorno donde se creó el backup es seguro**. Esto genera riesgos reales:

- **Corrupción silenciosa**: Datos alterados que pasan desapercibidos
- **Manipulación maliciosa**: Backups modificados por atacantes
- **Auto-verificación ciega**: Un script que verifica sus propias creaciones no es auditoría real

---

## 🏗️ Arquitectura de la Solución

Sistema basado en **separación de responsabilidades** con dos componentes independientes:

### 🔐 **Producer**: `backup_seguro.sh`
- Crea backups comprimidos
- Genera hash SHA-256 para integridad
- Firma digitalmente con GPG para autenticidad
- **Responsabilidad**: Garantizar que el backup nace íntegro y auténtico

### 🔍 **Auditor**: `verificador_backup.sh` 
- Verifica cualquier backup, sin importar su origen
- Valida hash SHA-256 contra corrupción
- Verifica firma GPG y emisor contra manipulación
- **Responsabilidad**: Auditoría imparcial y reproducible
