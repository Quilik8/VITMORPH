# Vitmorph — contrato aprobado de demo técnica

> Antecedente implementado en checkpoint-v0.7.0. Correcciones posteriores en DEMO_SCOPE.md: el refugio final será grande, con personajes y entrada a otra instancia; la historia es única y la demo integrará assets del usuario. La ubicación del refugio en el mismo mapa descrita debajo corresponde al prototipo anterior. Las reglas mecánicas no sustituidas conservan vigencia; UI y mapa requieren revisión.

4 octubre 2026. El usuario autorizó implementar el plan completo, pruebas automáticas, MCP y versionado. Valores técnicos provisionales; no son balance de campaña.

## Ciclo y reglas

Build → explorar → combatir → copiar → incorporar modular → desafío final → guardar/continuar. Un principal seleccionable desde colección fuera de combate. Dos fijas, dos modulares sin duplicados, ocho ranuras normales y dos especiales reservadas sin efectos nuevos. Biblioteca global reutilizable. Mod normal afecta todas las compatibles. Alcance +30 %, suma de porcentajes sobre base. Defensas propias no adquieren distancia.

Editor voluntario B y colección C: pausan solo exploración, limpian movimiento retenido, no aparecen antes de encuentros. P/R conservados; vista previa/aplicación conjunta. Comandos por identidad, reutilización persistente, no curación por edición/cambio.

ATB continuo; acción 4,8 s, impacto 2,2 s. Estados: 4 daño cada 4 s hasta 12 s; ralentización 25 % por 8 s. Reaplicar conserva mayor intensidad/extiende vencimiento y no reinicia pulsos. Reloj común, daños antes de copia, expiración después. Protecciones comunes; estados terminan con encuentro.

Copia: objetivo vivo ≤30 %, reserva próxima oportunidad como apoyo, revalidación al despacho; proceso 18 s desde resolución. Una solicitud/proceso, cancelar solo pendiente. Éxito añade copia a vida completa sin estado de combate, desbloquea modulares y retira vivo original. Caída/muerte/fin antes de completar falla. No evita daño letal. Copias conservadas en derrota resuelta; cierre durante batalla restaura antes del encuentro y revierte adquisiciones de esa batalla.

Refugio en mismo mundo. Descanso recupera colección/limpia reutilización y restablece encuentros. Derrota devuelve a refugio conservando colección/builds. Guardado por punto seguro, previo encuentro y tras cambios/resultado; JSON versionado y backup, trabajador único sin árbol de escena. Biblioteca y objetivos persistentes. Diagnóstico con perfil separado.

## Etapas y aceptación

0. MCP conectado, contrato y baseline tres repeticiones.
1. Catálogo Resource, colección/builds/compatibilidad y pruebas: 520/312/780, definiciones intactas → checkpoint-v0.2.0.
2. Theme compartido, editor/colección con skills UI y render 1200×820/1018×696/estrecho → checkpoint-v0.3.0.
3. Eventos/estados/IA/forecast con pruebas deterministas → checkpoint-v0.4.0.
4. Copia, retirada, biblioteca y adquisición con pruebas → checkpoint-v0.5.0.
5–6. Guardado/refugio/recorrido e hitos: copia, modular obtenida usada, final resuelto → checkpoint-v0.6.0.
7. Integración, tres capturas comparadas por caso, veinte reaperturas, cinco recorridos, nueva/restaurada, export Windows sin MCP → checkpoint-v0.7.0.

Cada hito requiere pruebas, evidencia, documentación, commit/subida. Suite antigua incompatible no certifica ATB. No imágenes ni aliados/reserva/Parry/combos/puzzles/economía/rangos/movimiento táctico. Skills ui-design-core/godot-ui-design/ui-visual-qa obligatorias para UI. Margen: p95 sin regresión >10 % inexplicada, CPU de simulación p95 objetivo <1 ms, memoria/nodos estabilizados; medir frío/caliente y no atribuir scopes CPU a GPU o RAM del proceso.

## Seguimiento

Las decisiones previas pendientes de BUILD_DESIGN y SYSTEMS_DESIGN quedan sustituidas por este contrato donde coinciden. En particular el mundo se pausa al editar, y copia retira al original. Implementación/evidencia de cada hito en CHANGELOG y VALIDATION.
