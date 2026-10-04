# Vitmorph · revisión de UI y paleta, 4 octubre 2026

## Brief de implementación

Petición: mejorar UI/estética y eliminar predominio de verdes. Objetivo del editor: identificar la copia, reconocer sus piezas y anticipar el resultado antes de aplicar. Primaria: Aplicar a esta bestia; selección de principal es independiente.

Dirección provisional: carbón/tinta, marfil, cobre/ámbar y azul grisáceo para resultado. Verde deja de ser fondo dominante. Extender Theme y trasladar sus colores a campo/HUD sin modificar geometría, combate o mapa.

Cambio estructural: bestia más grande dentro de una superficie de taller; colección como fichas compactas; biblioteca como cuadrícula de piezas con espacio de imagen y nombre; cuatro habilidades como elementos equipados reconocibles; comparación solo pertinente; estado pendiente y confirmación separados en el pie. Suprimir instrucciones y datos repetidos del estado vacío. Representaciones geométricas identificadas como técnicas hasta recibir assets.

Persistente: copia/principal, equipo y disponibilidad. Contextual: mejora seleccionada, efecto, compatibilidad y retiro. Transitorio: rechazo/montaje/aplicación. Diagnóstico: fórmulas en tooltip. Selección, foco, ocupado, reservado y pendiente mantienen señales textuales además de color.

Inputs: selección y drag and drop existentes, Tab/flechas/Enter/Escape. Ventana estrecha reordena sin reducir toda la interfaz. Preservar controller, builds independientes, propiedad de mods, pausa y guardado. No generar imágenes.

Revisión requerida: MCP de lectura, render antes/después, ventanas amplia/estrecha, seleccionar habilidad/mod/destino y estado pendiente. Sin añadir suite de tests no solicitada. La aprobación de UX/artística corresponde al usuario.

## Resultado implementado y evidencia

- Theme carbón/marfil/cobre y azul grisáceo para resultados; aplicado al editor, HUD y geometría provisional del mundo. Sin nuevos assets ni cambio de mapa/reglas.
- Biblioteca en cuadrícula con espacio de imagen, marcas técnicas cuando faltan assets y estados disponible/equipada/montado. Bestia de mayor tamaño y superficie de taller. Habilidades fijas/modulares con identidad consistente; pestaña activa y cambios modulares pendientes identificados.
- Comparación contextual omite propiedades sin cambio cuando no son pertinentes. Selección de mod resalta habilidades compatibles. Pulsar destino abre su biblioteca. En estrecho el foco conecta biblioteca y destinos; los elementos permanecen en scroll, no se reduce todo a tamaños ilegibles.
- Correcciones tras observar: habilidades cortadas por altura del taller, relleno de montaje que tapaba su marca y restauración diferida de foco que anulaba el salto al destino.

MCP: probe de lectura `application/config/name=Vitmorph`, reinicio de playtest en el editor existente y capturas. Base física 1018×696; nueva ventana amplia observada **1100×751/752**, contenido lógico 1200×820. Estrecha física **696×752**, contenido lógico 760×820. Intentar modificar directamente el tamaño embebido no obtuvo 1018×696; no se afirma validación física de 1200×820.

Evidencia en `tests/evidence/ui_before_charcoal.png`, `ui_charcoal_final.png`, `ui_charcoal_mod_detail.png`, `ui_charcoal_narrow_final.png`, `ui_charcoal_combat.png` y `ui_charcoal_world.png`. Entrada MCP `click_node` seleccionó Impacto residual y Modular 1; lectura confirmó cambio del borrador sin aplicar. En estrecho, Enter sobre la pieza movió foco a Modular_0 y un segundo Enter la equipó. Escape cerró una decisión pendiente. Consola MCP al cierre de revisión: cero entradas de error.

El intento de arrastre mediante eventos de ratón inyectados no inició un drag nativo (`native_drag_count=0`); esta revisión no certifica arrastre de extremo a extremo. Sus handlers se conservan, pero requiere una revisión de input real adicional. No se ejecutó suite automática ni perfilado; no se afirma ausencia de regresiones mecánicas o de rendimiento completa.

Se restauró el borrador previo a la sesión (Alcance en montaje 4) sin aplicarlo al guardado. Cambios de observación no se guardaron como nueva build. El editor queda abierto para revisión del usuario. Presentación artística pendiente de assets y aceptación de UX pendiente.
