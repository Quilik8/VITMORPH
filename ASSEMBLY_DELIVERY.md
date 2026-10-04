# Vitmorph · editor de ensamblaje

**Estado posterior a esta entrega:** el usuario rechazó la composición por seguir siendo casi la misma UI. La evidencia siguiente describe funcionamiento y revisión histórica; no representa aceptación del diseño. Pendientes: rediseño de experiencia/composición e integración artística. Diagnóstico, referencias comunitarias y propuesta de skill: [GAME_UI_RESEARCH.md](GAME_UI_RESEARCH.md).

4 octubre 2026. Implementación sobre la base 82d8e1a; checkpoint-v0.7.0 se conserva. El sistema usa representación técnica mientras llegan los assets del usuario. Esta entrega no certifica la presentación artística final ni reexporta el ejecutable 0.7.0.

## Probar y comprender el ensamblaje

Abrir project.godot con Godot 4.7.2 y ejecutar F5. Fuera de combate, B o C abre el editor y pausa exploración. No se impone un menú antes de un encuentro.

1. Elegir una copia en la tira superior. Su nombre e identificación permanecen en cabecera. Dos copias de la misma especie conservan builds distintas; editar no cambia el principal.
2. Para una modular, abrir Habilidades y seleccionar una habilidad seguida de Modular 1/2, o arrastrarla a esa ranura. Las fijas no se reemplazan; repetir la misma modular se rechaza.
3. Para un mod, abrir Mods y seleccionar una mejora seguida de un punto sobre la bestia, o arrastrarla allí. Ocho puntos normales; E1/E2 están reservados y deshabilitados. Los puntos son ubicaciones visuales, sin reglas anatómicas.
4. La comparación muestra el resultado del borrador y una propuesta antes de montar. Alcance modifica ataques compatibles: básico 400→520, cercano 240→312 y distante 600→780. Defensa permanece sobre el propio actor.
5. Aplicar a esta bestia confirma conjuntamente. Descartar restaura build y apariencia aplicadas. Vida, reutilizaciones e identidades se conservan; marcas siguen las reglas previas de habilidad equipada.

Mover un mod desde su punto intercambia posiciones si el destino está ocupado. Reemplazar devuelve el anterior al inventario del borrador. Retirar es explícito: soltar fuera no elimina. Una instancia ocupada por otra copia muestra propietaria e ID; primero retirarla y aplicar allí para trasladarla. Las habilidades desbloqueadas son reutilizables entre bestias.

Cerrar, cambiar copia o elegir principal con cambios pendientes ofrece Aplicar / Descartar / Seguir editando. Un error de validación mantiene abierto el borrador. Tab/Mayús+Tab y flechas recorren controles; Enter activa; Escape cancela primero operación/decisión/selección y luego solicita cerrar. El desplazamiento acompaña el foco. En combate no se abre el editor.

## Composición y revisión visual

Se aplicaron ui-design-core, godot-ui-design y ui-visual-qa. Theme compartido cálido: fondo verde oscuro, tinta clara, acentos dorados y texto de resultado. Una superficie sin paneles anidados; bestia central, habilidades debajo, biblioteca lateral y detalle contextual. Datos completos mediante tooltip. La comparación no es una pantalla obligatoria de preparación.

MCP configurado, probe de lectura application/config/name=Vitmorph, un editor/addon. Capturas reales del runtime: superficie amplia a **1018×696 físicos**, con contenido lógico 1200×820; estrecha a **645×696 físicos**, contenido lógico 760×820. Cambiar size de la ventana embebida no obtuvo una captura física 1200×820; no se presenta ese tamaño como revisado físicamente. En estrecho, biblioteca/detalle pasan debajo y el cuerpo se desplaza verticalmente, conservando cabecera/selector/pie.

Correcciones observadas y verificadas: el dibujo de puntos tapaba etiquetas; se dejó contorno. E2 se solapaba con un montaje normal; se separaron anclajes técnicos. La fila de fijas con iconos opcionales envolvía texto letra por letra; se corrigió expansión horizontal. El cacheado conservaba atenuación de destinos incompatibles tras montar; se restablece al refrescar. Biblioteca/contexto estrechos se revisaron también desplazados.

Las pruebas de cambios rápidos detectaron restauraciones de foco diferidas dirigidas a controles ya retirados. Se resuelve ahora el control vigente por nombre y se comprueba que continúa en el árbol visible antes de enfocarlo; se repitieron los flujos tras la corrección y se comprobó la consola.

Capturas en tests/evidence/assembly_*.png. La revisión confirma lectura técnica y operaciones observadas; la comprensión final y el estilo con arte requieren evaluación del usuario.

## Arquitectura y conservación de reglas

| Archivo | Responsabilidad |
|---|---|
| systems/build_draft.gd | Borrador independiente, equipar, retirar, intercambiar, validar, comparar, aplicar y descartar |
| ui/build_editor.gd | Composición y solicitudes del jugador, selector, decisiones pendientes y foco |
| ui/assembly_item.gd | Arrastre nativo de Control con payload de IDs/origen/copia y destino explícito |
| data/visual_asset.gd | Resource de presentación para una definición |
| data/visual_library.gd y .tres | Biblioteca visual editable |
| systems/visual_catalog.gd | Referencias/tipos/transformaciones válidas y diagnóstico de ausencias |
| ui/beast_visual.gd | Cuerpo, capas y efectos en editor y arena |
| ui/arena_view.gd | Posición/culling y eventos de ejecución/impacto |

La UI usa validate_build, preview_build y apply_build existentes. Resources compartidos no contienen vida, build ni estado mutable de una copia. Guardado conserva IDs y ranuras; no serializa texturas, escenas ni anclajes. Editor representa borrador; arena representa configuración aplicada. Capas estáticas no tienen _process. Efectos breves: una emisión por montaje aceptado, máximo doce transitorios por componente y liberación por duración. Retirar/configurar elimina capas y efectos anteriores. Ejecución/impacto reaccionan a eventos sin alterar daño ni ritmo.

## Incorporar assets sin cambiar código por imagen

No se recibieron assets finales en este bloque. Biblioteca vacía y figuras técnicas son intencionales; los tests usan PlaceholderTexture2D y escenas Node2D vacías en memoria, no arte generado.

1. Registrar la entrega en ASSET_REQUESTS.md: ID, ruta, revisión, procedencia, uso, escala, anclajes y aprobación. Recibido no equivale a aprobado.
2. Conservar fuentes del usuario y colocar exportados acordados en carpetas del proyecto. No hay importación arbitraria desde el editor del jugador.
3. En Godot crear un Resource **VitmorphVisualAsset** y guardarlo como .tres. Elegir kind beast/skill/modifier y definition_id existente del catálogo. revision, source_note y approval registran procedencia/estado.
4. Beast: icon es retrato; body, representación del editor; world_body opcional para mundo/combate, con body como alternativa. Mod: icon y mounted_layer transparente. Skill: icon y efectos de ejecución/impacto opcionales. Fijas también admiten icono.
5. En la presentación de especie, editor_anchors y world_anchors contienen diez Vector2 normalizados entre 0 y 1: ocho normales seguidos de dos especiales. Vacío usa anclajes técnicos. anchor_scales, anchor_rotations (radianes) y anchor_z tienen diez valores si se usan; z negativo dibuja detrás. mounted_size del mod define proporción respecto al cuerpo. El cuerpo conserva aspecto; anclajes se calculan sobre el área dibujada.
6. Referenciar escenas con raíz Node2D en equip_effect, persistent_effect, execution_effect e impact_effect, según el contenido aprobado. effect_seconds es duración positiva del transitorio. Efectos de Alcance excluyen Defensa propia. Una escena puede incluir componentes de audio; esta entrega no define sonidos finales ni un catálogo de efectos específicos.
7. Añadir el recurso a entries en **data/visual_library.tres** y reiniciar ejecución para cargarlo. No editar código para cada imagen. Consultar snapshot().visual_assets para problemas. IDs duplicados/desconocidos, texturas sin tamaño, transformaciones no finitas, duración inválida y raíz incompatible se diagnostican; ausencia conserva nombre/geometría técnica y no bloquea reglas.
8. Revisar escala, delante/detrás, montaje/retirada, coherencia mundo/editor y consumo con una muestra real antes de ampliar el paquete. El límite de transitorios no limita nodos internos, partículas o texturas de una escena aportada.

Referencias oficiales consultadas: [Control y arrastre nativo](https://docs.godotengine.org/en/stable/classes/class_control.html), [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html). La validación efectiva se realizó con el editor instalado 4.7.2.

## Pruebas y evidencia reproducible

- 112 comprobaciones mecánicas vigentes aprobadas en seis suites: builds, ATB/estados/IA, copia, guardado, recorrido y bordes. Las 33 históricas de iniciativa virtual se excluyen explícitamente.
- 22 comprobaciones de ensamblaje: equivalencia selección/arrastre, copias, reemplazo/intercambio/retiro, duplicados/propiedad, aplicación sin alterar estado y recursos ausentes/inválidos.
- Nueve de flujo de editor: decisiones pendientes, fallo conservando borrador, edición/principal, cierre y pausa/reapertura.
- Once de presentación: capas detrás, efectos de montaje/acción/impacto, compatibilidad, límite/liberación y build aplicada en mundo frente a borrador.
- Entrada observada: arrastre nativo aceptado, movimiento, Escape y soltar fuera; teclado Mayús+Tab/Enter resolvió Descartar y cambiar copia sin elegirla principal. Otros casos usan operaciones y fixtures aislados, no se presentan como pruebas humanas.

MCP input_simulate omite button_mask de MouseMotion. El helper tests/assembly_runtime.gd, invocado mediante MCP, envía eventos reales a Viewport con máscara mantenida; se verificó que Godot llamó _get_drag_data. No se modificó el addon. Los perfiles de diagnóstico restauran sesión/mundo originales y usan un archivo de guardado separado.

Reproducir desde MCP sobre /root/Main: run_assembly_checks(), las seis run_*_demo_checks/run_journey_checks/run_edge_checks; assembly_diagnostics('editor'/'presentation'/'cycles'/'effects'). Esperar report.running=false antes de iniciar otro driver. El modo begin conserva sesión para pointer_drag y requiere finish() al terminar. compare necesita copiar **82d8e1a:ui/build_editor.gd** a la ruta ignorada .codex/legacy_build_editor.gd; usa mismo Theme/sesión y descarta primer par de calentamiento.

Evidencias JSON: assembly_validation.json, assembly_performance.json, assembly_effects.json. Comprobación de scripts y consola por MCP; diff --check. Evidencia del ejecutable anterior permanece histórica, sin atribuirla al nuevo editor.

## Rendimiento y límites

Tres capturas equivalentes de tres segundos antes/después, tres pares de apertura/actualización síncrona tras calentamiento y veinte reaperturas. p50/p95/p99/máximo, tirones, scopes y monitores se conservan completos en JSON; scopes anidados no se suman. Los perfiles del editor embebido incluyen ruido de diagnóstico y no dan tiempo directo de GPU ni RAM del proceso.

El primer montaje reconstruía demasiados controles. Se añadieron firmas para reutilizar colección, habilidades y biblioteca cuando no cambian, y se eliminó refresco duplicado del borrador. Comparación final de tres pares: medianas de apertura anterior 24,774 ms / nuevo 21,373 ms; actualización anterior 28,302 ms / nuevo 28,170 ms. En tres muestras el p95 coincide con el máximo: apertura 25,127→21,773 ms; actualización 29,287→29,300 ms (≈+0,04 %). La nueva operación también valida la build; comparación limitada a ese escenario técnico.

Intervalos reales p95 antes: 18,705 / 19,166 / 18,773 ms; después: 17,562 / 18,859 / 19,021 ms. Mediana 18,773→18,859 ms (≈+0,46 %, dentro del 10 %). Tirones >33,33 ms: 0/1/1 antes y 0/0/1 después; ninguno >50 ms. El editor visible añade 28 nodos y nueve recursos frente a la UI anterior (112→140 y 58→67); draw calls 69→116 por cuerpo, diez puntos y más controles. Es un coste explícito del ensamblaje pausado, sin crecimiento por reapertura; no se extrapola al HUD de combate. Memoria gráfica muestreada cambia 22,42→15,51 MB, pero buffers/atlas del renderer varían entre sesiones: no se atribuye ese descenso a una optimización de assets.

Veinte ciclos repetidos tras corregir foco: nodos 148→148, recursos 67→67, huérfanos 0; texturas 7.066.517 bytes, buffers 8.619.418 bytes y memoria gráfica 15.685.935 bytes constantes. Asignaciones del motor +34.968 bytes incluyen el registro creciente de veinte mediciones; objetos permanecen 2089. Apertura CPU p95 31,165 ms y actualización selección+montaje p95 70,707 ms: esta última mide dos interacciones y refrescos, no equivale a una sola operación del comparador. Sigue siendo un coste puntual apreciable mientras exploración está pausada; no se presenta como actualización inferior a 1 ms. Consola sin líneas de error después de repetir flujos/editor/presentación/ciclos con la corrección.

Tres capturas con infraestructura de efectos: spawn p95 0,808 / 0,860 / 0,727 ms y transitorios liberados. Escenas vacías solo prueban asignación, eventos y limpieza. Rendimiento con partículas, shaders, sprites, audio y efectos reales sigue pendiente de una muestra del usuario. No prometer margen de GPU sin medir esos assets.

## Pendientes y continuidad

Sistema técnico implementado y versionado. Pendientes: primera muestra artística, revisión humana del ensamblaje, perfilado de sus assets y futura exportación actualizada. El mapa exterior, refugio amplio en otra instancia e historia única conservan sus bloques de diseño separados. No se añadieron reglas anatómicas, efectos de ranuras especiales ni nuevas mecánicas de combate.
