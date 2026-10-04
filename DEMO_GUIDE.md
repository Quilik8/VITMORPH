# Demo técnica de Vitmorph · 4 de octubre de 2026

> Guía del prototipo checkpoint-v0.7.0. La demo con assets y el refugio grande en otra instancia están pendientes de construcción; alcance vigente en DEMO_SCOPE.md. Las instrucciones siguientes describen el comportamiento existente.

## Jugar

Ejecutar `dist/Vitmorph.exe` o abrir `project.godot` con Godot 4.7.2 y pulsar F5.
La partida válida se recupera automáticamente. Un solo principal; figuras y balance provisionales.

| Acción | Control |
|---|---|
| Explorar en cualquier dirección | WASD / flechas |
| Editor voluntario de builds | B |
| Colección y elección de principal | C |
| Descansar en el refugio | E |
| Elegir habilidad en batalla | 1–4 / clic |
| Priorizar / quitar prioridad | P |
| Retener / liberar | R |
| Copiar objetivo / cancelar solicitud pendiente | X |
| Diagnóstico de combate | F3 |
| Navegar UI / activar / volver | Tab, Mayús+Tab, flechas, Enter, Escape |

Abrir builds o colección pausa la exploración. En el editor actual del proyecto, cerrar o cambiar copia con cambios pendientes ofrece Aplicar / Descartar / Seguir editando. El ejecutable 0.7.0 conserva la UI anterior. No se abre un menú antes de combatir.
Fijas pertenecen a la especie; dos modulares se eligen de la biblioteca, sin duplicados en una bestia.
Ocho ranuras normales, dos especiales sin efectos en esta demo. Alcance +30 % modifica todos los ataques compatibles y no afecta Defensa.
Elegir principal o aplicar una build conserva vida y reutilizaciones. Una instancia de modificador no se equipa simultáneamente en dos bestias.

### Ensamblaje actual en el proyecto

B/C abre la misma superficie con selector de copias. Editar una copia no cambia el principal. Para cambiar una modular: Habilidades → habilidad de biblioteca → Modular 1 o 2, o arrastrar a esa ranura. Las fijas no se reemplazan. Para un mod: Mods → mejora → punto numerado sobre la bestia, o arrastrar al punto. Los puntos E1/E2 están reservados.

Mover un mod montado intercambia posiciones; Retirar devuelve la instancia al inventario del borrador. Soltar fuera no retira. Aplicar a esta bestia confirma conjuntamente; Descartar restaura la configuración aplicada. Una instancia ocupada indica su copia propietaria: retirarla y aplicar allí antes de trasladarla. La comparación de alcance explica el efecto y Defensa queda fuera de ese modificador.

Tab/Mayús+Tab y flechas navegan; Enter activa el control enfocado. Escape cancela primero arrastre/selección/decisión y luego solicita cerrar. La ventana estrecha desplaza biblioteca y detalle debajo; el foco acompaña el desplazamiento. Informe y assets: [ASSEMBLY_DELIVERY.md](ASSEMBLY_DELIVERY.md).

## Completar el ciclo

1. Equipar Alcance si se desea y salir del editor.
2. Rodear el primer obstáculo y llegar al claro de copia. El combate comienza en ese lugar.
3. Debilitar al enemigo hasta 30 PV o menos; seleccionar el objetivo en la fila de apoyo y solicitar Copiar.
4. La próxima oportunidad del principal ejecuta apoyo. Desde su impacto transcurren 18 segundos de combate normal.
5. Mantener vivo al objetivo mediante Priorizar y Retener. Retener no detiene daño periódico ya aplicado; no existe protección contra daño letal.
6. Al completar, el original se retira vivo, la copia entra en la colección y sus modulares quedan disponibles para otras bestias.
7. Fuera de combate, incorporar una modular recién obtenida y usarla en batalla. Continuar al encuentro final.

Tres hitos registran la demo: copia obtenida, modular nueva utilizada y victoria final. No impiden acceder al final antes de obtenerlos. El mundo permanece explorable.
El segundo grupo confronta y puede regresar a su lugar si se abandona la persecución antes de combatir.
Descansar recupera la colección y restablece encuentros, conservando builds, biblioteca y finalización.
La derrota devuelve al refugio y conserva las copias completadas en esa sesión.

## Guardado

`%APPDATA%\Godot\app_userdata\Vitmorph\vitmorph_demo.json`; respaldo con sufijo `.bak`.
Se guarda al aplicar builds, elegir principal, descansar y resolver encuentros; también antes de entrar en batalla.
Cerrar durante una batalla recupera el punto anterior: las copias de esa batalla interrumpida se revierten.
El mensaje «Guardado» aparece solo tras confirmar la escritura. Corrupción intenta respaldo. Referencias o esquema incompatibles se conservan y bloquean sobrescritura.
Las pruebas automáticas usan `user://tests`, y los fixtures de diagnóstico conservan/restauran el recorrido de demo en memoria sin escribirlo.

## Alcance y límites

ATB continuo, cola con repeticiones, acciones 4,8 s, impacto 2,2 s, exploración 180 unidades/s.
Residuo hace 4 de daño a los 4/8/12 segundos; ralentización reduce un 25 % la carga futura durante 8 segundos.
Estados se limpian al finalizar el encuentro. La vida perdida se conserva hasta descansar o recuperarse tras derrota.
Sin aliados, reserva, Parry, movimiento táctico, combos, economía, progresión ni arte generado.
Obstáculos afectan navegación; no bloquean ataques ni añaden desplazamiento como acción de combate.
La aceptación de experiencia y balance requiere jugar la demo contigo. Las comprobaciones técnicas no convierten estos valores en canon definitivo.
