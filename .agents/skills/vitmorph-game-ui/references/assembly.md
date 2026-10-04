# Ensamblaje, colección y piezas

Consultar el contrato vigente de BUILD_DESIGN.md antes de cambiar comportamiento.

## Reglas de Vitmorph

- Cada copia posee build independiente; editarla no la convierte en principal. Distinguir copias de una especie sin inundar la vista de IDs internos.
- Dos fijas no reemplazables, dos modulares, ocho montajes normales y dos especiales reservados/deshabilitados mientras no tengan reglas aprobadas.
- Modulares desbloqueadas reutilizables entre bestias, sin duplicarlas en la misma copia. Mods como instancias: si está ocupada por otra copia, indicar propietaria y bloquear hasta retirar y aplicar allí.
- Anclajes corporales visuales, sin compatibilidad anatómica. No dibujar enlaces que hagan creer que un mod afecta solo a una parte o habilidad cuando su regla es global para las compatibles.
- Selección y destino o drag and drop llaman a la misma operación del borrador. Soltar entre puntos no elige un destino automáticamente.
- Reemplazar devuelve al inventario del borrador; mover intercambia si está ocupado; retirar es explícito; soltar fuera/Escape cancela sin eliminar.
- Aplicar es conjunto y conserva identidad, vida y reutilizaciones. Marcas de habilidad respetan las reglas existentes. Cambiar copia, principal o cerrar con pendientes ofrece Aplicar / Descartar / Seguir editando.
- Editor voluntario fuera de combate, exploración pausada, teclas retenidas limpiadas. No introducir una preparación obligatoria antes del encuentro.

## Relaciones visuales

La colección responde «quién edito». El cuerpo, «qué tiene montado». La biblioteca, «qué puedo añadir». El detalle, «qué hará aquí». La confirmación, «qué está pendiente». No dar el mismo peso a todas esas preguntas.

Conservar identidad de la pieza entre inventario, selección, arrastre y montaje. Destino y disponibilidad visibles. Al seleccionar Alcance, resaltar ataques compatibles y mostrar cambios; Defensa propia no recibe distancia ficticia. No usar la palabra «compatible» como único vínculo perceptivo.

Diferenciar aplicada, pendiente y seleccionada con forma, etiqueta, contorno o representación además de color. No confundir foco con equipamiento. El mundo presenta solo la build aplicada. Los puntos vacíos son discretos hasta ser relevantes; los ocupados muestran qué pieza contienen.

En estrecho, revisar biblioteca→destino→comparación→confirmación como interacción completa. Selección es alternativa al arrastre si no caben ambas zonas; no afirmar equivalencia espacial cuando el destino queda fuera de vista.

## Referencias traducidas al proyecto

- Hollow Knight: siluetas memorables y colección ordenada, detalle de selección en vez de fichas completas permanentes. No copiar muescas, sobrecarga o bancos.
- Warframe: gramática compartida entre pieza disponible y montada. No copiar polaridades/capacidad/progresión/propiedad.
- Destiny: build y resultado juntos. No inventar presets para justificar navegación.
- Monster Hunter: nombre temático acompañado del efecto donde se decide. No exigir memoria previa de nombres.
- Hades: acceso al contexto necesario desde la decisión. No añadir bendiciones aleatorias o mecánicas roguelike.

## Assets

Recursos por ID: retrato, representación, imagen de habilidad/mod, capa y efectos opcionales; anclaje, escala, orientación y orden por contexto. Mantener revisión/aprobación en ASSET_REQUESTS.md. Guardado sin texturas, escenas o posiciones UI.

Comprobar transparencia, recorte, aspecto, lectura a tamaño real y capas delante/detrás. Icono de catálogo y capa corporal pueden ser distintos assets ligados al mismo ID. No estirar imágenes ni convertir ilustraciones complejas en iconos ilegibles por comodidad.

## Tareas de revisión

Identificar copia y principal; cambiar modular; montar/reemplazar/intercambiar/retirar mod; cancelar arrastre; reconocer propietaria ajena; explicar mejora; distinguir pendiente/aplicado; descartar y reabrir. Recorrer con Tab/flechas/Enter/Escape. Registrar dudas y fallos observados, no solo existencia de botones.
