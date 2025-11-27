🛡️ Arquitectura de Productor-Auditor para Integridad de Datos Críticos
Resumen del Proyecto
Este repositorio implementa una solución de respaldo de alta seguridad que garantiza la Integridad (SHA256) y la Autenticidad (GPG) de los datos críticos. Supera la vulnerabilidad de la "autoverificación" mediante la separación de responsabilidades en dos módulos independientes: Productor y Auditor. Este diseño resiste la manipulación por adversarios, asegurando que un respaldo corrupto o falsificado sea detectado inmediatamente.
