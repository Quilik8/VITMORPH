# Registro de cambios

## 0.1.0 · 3 de octubre de 2026 · punto recuperable del prototipo

- Combate automático, Priorizar/Retener, ATB y cola prevista con actores repetidos.
- Exploración del jugador y encuentros en el mismo mundo, sin pantalla de transición.
- Eliminación explícita del menú de preparación, variantes y Potencia añadidos por el agente y rechazados por el jugador.
- Terreno técnico ampliado a x=80…4000, y=80…2000 y cámara en ambos ejes. Movimiento con WASD/flechas y diagonales normalizadas.
- Previsión de cola almacenada y refrescada a 5 Hz o al cambiar el estado.
- Reutilización de rutas perseguidoras por 0,25 s; recalcular ante cambio de modo, destino desplazado o llegada al waypoint.
- Culling vertical además del horizontal para actores del campo.
- Integración Git con Quilik8/VITMORPH; código, decisiones y evidencia versionados.

Este punto no certifica un juego completo ni 60 FPS. Las pruebas antiguas de iniciativa virtual son históricas; el ATB conserva validación de ejecución documentada y casos pendientes. Movimiento de combate y bloqueo de ataques por terreno siguen pendientes.
