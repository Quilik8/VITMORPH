# Guardado y recorrido

22 pruebas de persistencia/refugio y 10 del ciclo completo aprobadas por MCP.
Las pruebas escriben user://tests; no alteran la partida visible.
Arranque real observado tras reiniciar desde MCP: Guardado recuperado, principal inicial, recorrido activo.
Una copia y sus modulares se obtienen a partir de daño normal en la prueba de ciclo, se equipan y superan al rival final.
El refugio permanece en la misma escena; descansar devuelve vida, protección y reutilizaciones de toda la colección y restablece los grupos.
Derrota resuelta recupera la colección y retorna al refugio; no elimina copias ni builds. Recuperación de vida completa en refugio es regla técnica provisional.
Guardado: JSON esquema 1, identidad estable y coordenadas simples; trabajador único recibe texto serializado.
Snapshot se crea en hilo principal, worker usa solo IO y parseo; orden de solicitudes y flush al cierre.
Temporal verificado, respaldo de archivo válido y sustitución; corrupción usa respaldo.
Esquema/referencias incompatibles conservan originales y bloquean sobrescritura incluso al recuperar respaldo.
El punto anterior al encuentro se conserva durante batalla; no se serializan ATB, estados ni procesos pendientes.
La demo tiene claro individual, paso de dos enemigos y final sin bloqueo de acceso; objetivo de uso de modular copiada cuenta ejecución real.
