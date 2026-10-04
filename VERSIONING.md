# Versiones recuperables de Vitmorph

Repositorio autorizado: https://github.com/Quilik8/VITMORPH

## Primer punto recuperable

`checkpoint-v0.1.0`: prototipo de exploración y combate ATB, sin pantalla de preparación. Evidencia y limitaciones en `VALIDATION.md`. Es un punto de recuperación del prototipo, no una versión de lanzamiento ni una certificación completa de estabilidad.

## Registro de cambios

Cada cambio se registra en un commit descriptivo y en `CHANGELOG.md`; decisiones de diseño y técnicas permanecen en sus registros respectivos. Las etiquetas posteriores se crean después de revisar el estado jugable y consignar el alcance comprobado. Las pruebas antiguas conservan su fecha y alcance; no certifican automáticamente el código actual.

## Recuperar sin perder trabajo

Desde un clon del repositorio, se puede crear una rama desde el punto guardado:

```sh
git fetch origin --tags
git switch -c recuperar-v0.1.0 checkpoint-v0.1.0
```

Primero guardar los cambios locales pendientes en un commit. Git bloquea cambios de rama que sobrescribirían modificaciones. Evitar restauraciones destructivas.

## Contenido

Se versionan proyecto, escenas, scripts, addon, documentación y evidencias. Se excluyen cachés `.godot`, temporales, configuración personal `.codex` y logs. Los documentos originales externos en Downloads no están dentro del proyecto.

## Demo técnica integrada · 4 octubre 2026

Puntos comprobados y publicados: `checkpoint-v0.2.0` (catálogo/builds), `checkpoint-v0.3.0` (editor/colección), `checkpoint-v0.4.0` (estados/IA), `checkpoint-v0.5.0` (copia) y `checkpoint-v0.6.0` (guardado/refugio/recorrido). El cierre `checkpoint-v0.7.0` reúne integración, 112 comprobaciones aprobadas, revisión MCP, estabilidad y exportación Windows 4.7.2 sin dependencia MCP. Detalle y límites en DEMO_DELIVERY.md. El ejecutable local se excluye de Git; se versiona el preset.

## Punto de optimización

`checkpoint-v0.1.1`: primera optimización medida de dibujo, con evidencia y límites en `PERFORMANCE.md`. Conserva `checkpoint-v0.1.0` para recuperar la base anterior. La etiqueta no certifica rendimiento constante ni juego completo.

## Segundo punto de optimización

`checkpoint-v0.1.2`: geometría retenida de indicadores, menor trabajo espacial en reposo, registros/cachés acotados y diagnóstico de fluidez/memoria/renderer. Evidencia y límites en `PERFORMANCE_HEADROOM.md`; no certifica escenas finales ni ausencia de tirones.
