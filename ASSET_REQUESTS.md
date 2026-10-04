# Vitmorph · lista de assets de la demo

Actualizado: 4 octubre 2026. Alcance vigente: [DEMO_SCOPE.md](DEMO_SCOPE.md). Este documento convierte la nota inicial en una lista de producción y recepción. Las cantidades pendientes no son requisitos cerrados.

## Reglas

- Todos los assets los aporta el usuario. No generar imágenes ni inventar contenido final.
- Refugio amplio, con personajes y acceso a otra instancia. Historia única, sin ramificaciones.
- El usuario decide contenido y arte final. La dirección de referencia sigue siendo Fábula Moderna Simplificada; referencias piloto no son assets integrados.
- Figuras técnicas y capturas de tests/evidence no son arte final. Fixtures técnicos no fijan especies, nombres ni cantidad de habilidades de la demo.
- «Por cada» indica cómo contar cuando el contenido esté aprobado. Ninguna fila implica archivos recibidos.
- Reutilizar recursos entre HUD, colección y editor cuando corresponda. Conservar identificación textual, foco y estados legibles sin depender solo del color.

## Inventario de necesidades

Estado inicial de todas las familias: **POR DEFINIR**. Las cantidades se cierran al aprobar el catálogo, mapa y escenas.

### Personaje y bestias

| ID | Material | Cómo contar | Dependencia |
|---|---|---|---|
| ACT-01 | Representación del personaje de exploración | Por personaje controlable aprobado | Qué representa, perspectiva y escala |
| ACT-02 | Reposo y movimiento | Por dirección/estado acordado | Técnica de animación y direcciones |
| BEA-01 | Bestia en mundo y combate | Por especie incluida | Catálogo artístico y escala relativa |
| BEA-02 | Reposo, acción, impacto y salida de bestia | Por animación necesaria | Puesta en escena; distinguir retirada viva y muerte |
| BEA-03 | Retrato/ilustración de colección | Por especie; variantes solo aprobadas | Brief de colección; varias copias pueden compartir arte |

### Habilidades, mods y combate

| ID | Material | Cómo contar | Dependencia |
|---|---|---|---|
| SKL-01 | Imagen/icono de habilidad | Por habilidad incluida | Catálogo final; uso compartido editor/HUD |
| SKL-02 | Anticipación y ejecución | Por familia visual necesaria | Origen, objetivo y sincronización |
| SKL-03 | Impacto, defensa y protección | Por efecto diferenciado | Lectura del resultado y absorción |
| STA-01 | Iconos de estados | Por estado incluido | Lectura a tamaño de HUD |
| STA-02 | Efectos visibles de estados | Por efecto necesario | Duración y legibilidad sobre la bestia |
| CPY-01 | Proceso de copia | Familia reutilizable; variantes pendientes | Dirección visual del proceso |
| CPY-02 | Éxito, fallo y retirada | Según presentación aprobada | Diferenciar copia y muerte |
| MOD-01 | Iconos de modificadores normales | Por tipo incluido | Ocho ranuras no exigen ocho tipos de mod |
| MOD-02 | Modificadores especiales | Sin solicitud de efectos por ahora | Sus reglas aún no están definidas |

### Mapa exterior y refugio

| ID | Material | Cómo contar | Dependencia |
|---|---|---|---|
| EXT-01 | Suelos, caminos y bordes | Por conjunto ambiental | Planta y método de montaje |
| EXT-02 | Obstáculos y elementos del entorno | Por familia/variante necesaria | Escala, colisión y oclusión |
| EXT-03 | Referencias visuales y espacios de encuentro | Por lugar definido | Recorrido menos lineal |
| EXT-04 | Elementos de aparición de enemigos | Según modalidad elegida | Visibilidad/aparición pendiente |
| REF-01 | Acceso al refugio | Por acceso aprobado | Ubicación y lectura de entrada a instancia |
| REF-02 | Suelo, caminos y límites del refugio | Por conjunto de zona | Planta y extensión accesible |
| REF-03 | Edificios y estructuras urbanas | Por lugar visible aprobado | No presuponer servicios ni una ciudad completa |
| REF-04 | Interiores | Solo los que se acuerde visitar | Cobertura de la demo; no asumir interiores accesibles |
| REF-05 | Objetos interactivos y referencias de orientación | Por interacción/lugar | Funciones del refugio |

### Personajes e historia única

| ID | Material/contenido | Cómo contar | Dependencia |
|---|---|---|---|
| NPC-01 | Sprites de personajes del refugio | Por personaje incluido | Elenco, función y ubicación |
| NPC-02 | Animaciones de personajes | Por acción necesaria | Escenas e interacciones; rutinas urbanas no asumidas |
| NAR-01 | Sinopsis y guion | Una trama, escenas enumeradas | Autoría/aprobación del usuario |
| NAR-02 | Diálogos | Por escena/interacción | Orden narrativo sin árboles ramificados |
| NAR-03 | Retratos y expresiones | Por interlocutor/expresión si se usan | Presentación narrativa pendiente |
| NAR-04 | Fondos e ilustraciones de escena | Solo escenas que los requieran | Visual novel/híbrido no aprobado todavía |
| NAR-05 | Voz/cinemáticas | Fuera de solicitud actual | No están aprobadas como entregas obligatorias |

### Interfaz

| ID | Material | Cómo contar | Dependencia |
|---|---|---|---|
| UI-01 | Tipografías y permiso de uso | Familias/estilos necesarios | Idioma y legibilidad |
| UI-02 | Superficies, separadores y ornamentos | Conjunto reutilizable si hace falta | Brief; evitar marcos repetidos sin función |
| UI-03 | Cursor, foco, selección y destinos de arrastre | Estados compartidos | Selección + drag and drop |
| UI-04 | Iconos de equipar, retirar, volver y aplicar | Según controles definitivos | Brief de interacción |
| UI-05 | Guardado y mensajes | Recursos propios solo si son necesarios | Comunicación compartida |
| UI-06 | Marca, título y cierre | Pendiente | Alcance final; no inventar logo |

### Audio

| ID | Material | Cómo contar | Dependencia |
|---|---|---|---|
| AUD-01 | Música exterior | Por ambiente aprobado | Mapa y dirección sonora |
| AUD-02 | Música/ambiente del refugio | Por ambiente aprobado | Identidad y transición entre instancias |
| AUD-03 | Música de combate | Piezas/variantes pendientes | Transición desde exploración y encuentro final |
| AUD-04 | Pasos y movimiento | Por superficie necesaria | Materiales y personaje |
| AUD-05 | Habilidades, impactos y defensa | Por familia de efecto | Sincronización con SKL-02/03 |
| AUD-06 | Estados y copia | Por evento que necesite confirmación | Inicio, éxito y fallo |
| AUD-07 | Selección, equipar, retirar, cancelar y error | Según interacción final | Evitar saturación por hover |
| AUD-08 | Ambiente y personajes | Por lugar/interacción | No asumir voces habladas |
| AUD-09 | Resultados y cierre | Pendiente | Tratamiento audiovisual del final |

## Ficha de entrega por asset concreto

Registrar:

1. ID estable, nombre, categoría, lugar de uso y recurso relacionado.
2. Autor/procedencia, permiso de uso y archivos fuente/exportado disponibles.
3. Cantidad, variantes y referencias aprobadas.
4. Imagen: dimensiones, transparencia, escala en juego, orientación, anclaje y capas.
5. Animación: técnica, direcciones, estados, fotogramas, duración y momentos de sincronización.
6. Audio: formato entregado, duración, mono/estéreo, loop y sincronización si aplica.
7. Dependencias, estado, ruta real, revisión y destino en el proyecto.
8. Resultado de integración: lectura, tamaño, memoria/carga y problemas pendientes.

No fijar resolución, FPS, direcciones o formatos finales sin probar una muestra real del usuario. Conservar originales y acordar derivados de integración. ASSET_PERFORMANCE_PLAN.md contiene propuestas técnicas que necesitan medición con contenido real.

## Registro de recepción

Estados: POR DEFINIR → ESPECIFICADO → RECIBIDO → APROBADO → INTEGRADO → VALIDADO. REVISION indica cambios solicitados y motivo. Recibir no equivale a aprobar ni validar en juego.

| ID concreto | Ruta recibida | Revisión | Estado | Destino | Observaciones |
|---|---|---|---|---|---|
| Sin entregas registradas en esta lista | — | — | — | — | No se ha auditado una carpeta de assets aportados |

Esto no afirma que el usuario carezca de material preparado. Registrar rutas reales cuando se reciban o se indique dónde revisarlas.

## Paquetes de integración propuestos

1. Muestra representativa: personaje, una bestia, habilidad, mod y suelo/obstáculo para probar escala y lectura.
2. Construcción: colección, habilidades/mods y estados de selección/arrastre, con builds distintas por copia.
3. Exterior/refugio: entorno, entrada a instancia y personajes aprobados; navegación y persistencia.
4. Historia única: escenas y recursos de la presentación elegida.
5. Combate/audio: kits, estados, copia y sonidos sincronizados.
6. Cierre: partida completa con assets, guardado y rendimiento.

El orden organiza dependencias; no aprueba contenido ni cantidades.

## Pendientes para cerrar cantidades

Personaje controlado/perspectiva; especies/habilidades/mods; planta del exterior y refugio; elenco y escenas; modalidad de enemigos; presentación narrativa/transición; escala y técnica de los primeros assets. Actualizar esta lista cuando cambie contenido aprobado. No convertir pendientes en decisiones para facilitar una sesión posterior.
