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
