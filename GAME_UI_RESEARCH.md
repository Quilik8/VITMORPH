# Vitmorph · investigación de interfaces de builds y skills

4 de octubre de 2026. Investigación previa a otro rediseño. Base examinada: commit `7ac300d`. **La composición del editor actual fue rechazada por el usuario por seguir siendo casi la misma.** Su funcionamiento técnico no equivale a aceptación de diseño.

**Actualización posterior:** investigación ampliada con Hollow Knight, Monster Hunter, Hades y Dead Cells en [GAME_UI_RESEARCH_EXTENDED.md](GAME_UI_RESEARCH_EXTENDED.md). El usuario autorizó crear la skill; ya existe [vitmorph-game-ui](.agents/skills/vitmorph-game-ui/SKILL.md) y AGENTS.md exige su uso. Las menciones siguientes a una skill todavía no creada describen el estado de la investigación inicial.

## 1. Resultado y límites de la investigación

La recomendación es añadir una skill personal de **diseño de interfaces para videojuegos**, complementaria a `ui-design-core` y `godot-ui-design`. Debe reforzar fantasía de interacción, jerarquía visual, objetos equipables, estados y evaluación por tareas. El problema anterior también fue de aplicación: las skills existentes ya advertían contra formularios genéricos, cambios cosméticos y validación basada únicamente en código.

No hay evidencia suficiente para declarar una UI de builds universalmente «la mejor según las comunidades». Se consultaron hilos de comunidades y documentación de desarrolladores: sirven para identificar aciertos y fricciones concretos, no constituyen una encuesta representativa. Elogiar un sistema de crafting tampoco significa aprobar toda su interfaz.

Se inspeccionaron visualmente la captura real de Vitmorph `tests/evidence/assembly_final_mounted.png` (1018×696 físicos), una imagen oficial de personalización de mods de Destiny 2 y una imagen histórica oficial de mods de Warframe. Armored Core VI y Last Epoch se estudiaron mediante textos y comentarios; no se afirma una revisión visual directa de sus interfaces actuales. Las imágenes oficiales de referencia no certifican la versión vigente de esos juegos en 2026. Una imagen comunitaria de Warframe quedó tras un CAPTCHA y no se inspeccionó.

El MCP configurado respondió a una consulta de lectura de nombre de proyecto y estado del editor. No se realizaron nuevas pruebas de entrada o rendimiento para esta investigación. No se modificó la UI, no se instalaron skills externas y no se generaron imágenes.

## 2. Qué hicimos mal en Vitmorph

| Fallo observado | Por qué conserva la sensación anterior | Corrección que debe demostrar el próximo diseño |
|---|---|---|
| La bestia es un polígono pequeño y tenue dentro de mucho espacio vacío | La biblioteca y los textos siguen siendo protagonistas perceptivos | La silueta y las mejoras montadas deben dominar la primera lectura, incluso con geometría provisional |
| Habilidades y mods siguen pareciendo filas de un formulario | Cambiar su ubicación no convierte la mejora en un objeto que se toma y monta | Lenguaje visual consistente entre pieza disponible, pieza seleccionada y pieza instalada |
| Añadimos círculos numerados sin transformar la relación entre regiones | Cambió la forma de los destinos, pero sigue siendo necesario leer instrucciones para entenderlos | Destinos explícitos, proximidad y respuesta visual que conecten selección, montaje y efecto |
| Instrucciones, identificadores y comparaciones sin cambio están siempre visibles | La información secundaria compite con la acción que se intenta realizar | Mostrar lo esencial para decidir; ampliar reglas y fórmulas en detalle contextual |
| El efecto sobre habilidades se explica principalmente con texto | El jugador no percibe con rapidez qué parte de su build acaba de mejorar | Resaltar habilidades afectadas y mostrar solo los cambios pertinentes antes de confirmar |
| Casi todos los elementos comparten tamaño, tipografía y subrayado | Una acción, una selección y una explicación parecen equivalentes | Diferenciar visualmente identidad, contenido equipable, estado y acción principal |
| En estrecho, biblioteca y bestia pueden quedar separadas por scroll | El reflow evita recortes, pero puede perjudicar el arrastre y la comparación simultánea | Revisar una interacción completa en esa ventana, no solo que el contenido quepa |
| La revisión privilegió funcionamiento y legibilidad | Pruebas de reglas y foco no demuestran aprendizaje, identidad ni sensación de ensamblaje | Evaluar tareas, errores y comprensión; separar corrección mecánica, UX observada y aprobación del usuario |

La falta de assets finales limita la evaluación artística, pero **no justifica una jerarquía débil o una interacción confusa**. El diseño debe funcionar con representaciones técnicas y estar preparado para recibir el material del usuario.

Tampoco corresponde prohibir rectángulos o cuadrículas: son útiles para catálogos y comparación. Lo que falló fue usarlos como estructura indiferenciada, junto con texto permanente y poca presencia de la bestia. Sustituirlos por círculos no resuelve por sí mismo el problema.

## 3. Referencias: qué aprovechar y qué evitar

### Warframe: identidad de las piezas y presencia del personaje

La [guía oficial de mods](https://www.warframe.com/en/news/mod-ja), publicada en 2019, documenta el acceso desde Arsenal/Upgrade y la relación entre mods y destinos. La [imagen oficial histórica de mods](https://www-static.warframe.com/images/mainSiteAssets/quickstartPage/qs-mod1.jpg) muestra una gramática compartida entre cartas del inventario y huecos equipados, junto al personaje y sus propiedades. Es una referencia de organización visual, no una especificación de las reglas actuales.

La comunidad también señala problemas: un [hilo sobre cambios de la pantalla de mods](https://www.reddit.com/r/Warframe/comments/1o7sdpp/feedback_the_new_mod_screen_ui_is_less/) critica pérdida de presencia del personaje, espacio desaprovechado y legibilidad; hay respuestas que no comparten toda la crítica. Un [hilo de 2022 sobre dificultades de modding](https://www.reddit.com/r/Warframe/comments/x43v3l/what_are_the_biggest_problems_with_the_mod_screen/) recoge dudas de aprendizaje y dependencia de explicaciones externas.

**Aplicación propuesta:** conectar pieza, destino y resultado conservando la bestia visible. No copiar complejidad, capacidad, polaridades o rangos. En Vitmorph los mods son instancias con propietaria y las modulares son reutilizables; una semejanza visual no cambia esas reglas.

### Destiny 2 / DIM: visión conjunta y cambios fiables

El artículo de Bungie [Buildcrafting Evolved, enero de 2023](https://www.bungie.net/7/en/News/article/buildcrafting) explica objetivos de reducir desplazamientos entre pantallas y reunir configuración y efectos. Su [imagen de personalización de mods](https://images.contentstack.io/v3/assets/blte410e3b15535c144/bltf9d87f6dcdda91e9/63c82b233377ed3ff87d9581/EN_3.JPG) permite observar un personaje grande, equipo identificado mediante imágenes, cuadrículas compactas y detalle contextual.

En [comentarios sobre DIM y loadouts, abril de 2023](https://www.reddit.com/r/DestinyTheGame/comments/12b9d7k/for_those_who_dont_know_yet_dim_now_can_edit/) aparecen elogios a la rapidez del cambio dentro del juego y al archivo/organización externa. El propio post corrige una afirmación inicial sobre qué puede guardar DIM: no debe repetirse como capacidad vigente. Un [hilo sobre sobrescritura accidental](https://www.reddit.com/r/DestinyTheGame/comments/11ok1ia/hopefully_we_can_lock_loadouts_in_the_future/) muestra el coste de perder una configuración por una acción poco protegida.

**Aplicación propuesta:** lectura conjunta, identidad inequívoca de cada copia y separación entre borrador y configuración aplicada. No añadir un sistema nuevo de presets por imitación.

### Last Epoch: explicar donde se decide

En [un hilo de febrero de 2024](https://www.reddit.com/r/LastEpoch/comments/1awsj6o/the_entire_game_is_selfexplanatory_bravo/) se elogia el detalle progresivo mediante tooltips y explicaciones junto a las propiedades. También hay una respuesta que necesita herramientas externas para valores más específicos. Otro [hilo de elogio al crafting](https://www.reddit.com/r/LastEpoch/comments/1azq7es/) contiene comentarios favorables a mostrar opciones elegibles, pero no demuestra unanimidad sobre la UI. Las [críticas a interacciones y tooltips](https://www.reddit.com/r/LastEpoch/comments/1b4s3bv/im_sure_ehg_knows_but_this_uiux_design_choice_needs/) recuerdan que una buena regla puede quedar perjudicada por acceso o comportamiento deficientes.

**Aplicación propuesta:** mostrar compatibilidad y consecuencia en el lugar de la selección; conservar acceso a cifras completas sin llenar la pantalla de instrucciones. No esconder un dato necesario para decidir detrás de varios pasos.

### Armored Core VI: ensamblar un ser reconocible

La [presentación oficial del juego](https://www.bandainamcoent.com/games/armored-core-vi-fires-of-rubicon) vincula personalización de piezas y comportamiento en batalla. Es una analogía de producto valiosa para el objetivo de ensamblar mejoras. Sin embargo, [jugadores que preguntan por iconos y especificaciones](https://www.reddit.com/r/ArmoredCoreVI/comments/16ihv7d/weapon_specs_icons/) y [un debate sobre aprendizaje y explicaciones](https://www.reddit.com/r/armoredcore/comments/191vwue/does_the_game_intentionally_do_a_poor_job/) evidencian fricción y experiencias distintas; el acceso a ayuda, entrenamiento y prueba forma parte del contexto.

**Aplicación propuesta:** que una modificación se perciba en el ser y pueda relacionarse con su función. No trasladar límites anatómicos, peso o energía: la ubicación corporal de los mods en Vitmorph es visual.

### Selección por criterio, sin ranking universal

| Necesidad de Vitmorph | Referencia más útil en esta investigación | Precaución |
|---|---|---|
| Sentir que se montan piezas | Warframe y analogía de Armored Core VI | Preservar reglas propias y evitar complejidad oculta |
| Ver build y resultado juntos | Pantalla de mods de Destiny 2 | No convertir todo en números pequeños o copiar sus sistemas |
| Comprender compatibilidad y cambios | Comentarios de Last Epoch | Detalle progresivo sin esconder decisiones esenciales |
| Conservar configuraciones sin errores | Experiencias de Destiny/DIM | Identidad, borrador y confirmación fiables |

## 4. Skills específicas encontradas

Se leyó el contenido de las siguientes candidatas; ninguna se instaló ni se ejecutaron sus scripts.

| Candidata | Aporte | Límite / decisión |
|---|---|---|
| [AgentSkills · game-ui-design](https://github.com/jeremylongworth-source/AgentSkills/blob/main/skills/game-ui-design/SKILL.md) | Contexto de juego, estados, inventario, comparación y entradas alternativas | Buena base breve, pero se solapa con nuestras skills y no desarrolla suficientemente ensamblaje ni aceptación perceptiva |
| [Skills for Antigravity · game-ui-design](https://github.com/omer-metin/skills-for-antigravity/blob/main/skills/game-ui-design/SKILL.md) | Biblioteca extensa de patrones de HUD, navegación y presentación | No adoptar literalmente: contiene credenciales de experiencia inventadas, prioridades universales de input y una instrucción que antepone referencias a lo que pide el usuario |
| [OpenAI game-studio · game-ui-frontend](https://github.com/openai/plugins/blob/main/plugins/game-studio/skills/game-ui-frontend/SKILL.md) | Lenguaje visual ligado al juego y separación entre interfaz y espacio de juego | Orientada a juegos web; sus herramientas y presupuestos de HUD no corresponden automáticamente a un editor pausado en Godot |
| [Unity Technologies · ui](https://github.com/Unity-Technologies/skills/blob/main/skills/ui/SKILL.md) | Elección y aplicación de frameworks de UI del motor | Es una guía técnica de Unity; no resuelve dirección artística ni es la plataforma del proyecto |

Encontrar una skill de videojuegos sí es posible. Instalar una genérica de terceros no garantiza corregir esta pantalla. Conviene una capa propia que recoja los vacíos reales sin duplicar instrucciones existentes ni copiar autoridad ajena.

## 5. Especificación de la siguiente skill

**Propuesta, todavía no creada:** `game-ui-design`. Aplicable a HUDs, inventarios, builds, colecciones y otras interfaces de videojuegos. Complementa el núcleo general y la skill del motor. Las reglas exclusivas de Vitmorph permanecen en sus documentos.

Responsabilidades que deben cambiar el trabajo del agente:

1. Definir fantasía de interacción y objeto protagonista. Distinguir un HUD bajo presión de un editor pausado; la misma densidad no sirve para ambos.
2. Estudiar referencias por tareas, estados y relaciones visuales. Registrar versión, evidencia observada y opiniones contradictorias; no crear rankings ficticios.
3. Para builds, diseñar la cadena **identificar copia → elegir pieza → reconocer destino → anticipar efecto → montar → confirmar**. Diferenciar selección, borrador y aplicado.
4. Tratar pieza disponible e instalada como el mismo objeto visual. Comparación localizada y destinos válidos visibles; rechazo con motivo comprensible. Selección y arrastre tienen equivalencia funcional.
5. Proponer una composición perceptiblemente distinta antes de implementar un rediseño importante. Un cambio de marcos, colores o geometría aislado no cuenta como nueva solución.
6. Preparar imágenes, escalas, recortes, capas y efectos sin depender de que el arte arregle la jerarquía. La dirección visual debe pertenecer al juego, no a una plantilla administrativa.
7. Revisar tareas completas con ratón y teclado en render real. Comprobar dónde se duda, qué se busca y qué se interpreta mal; no presentar tiempos humanos ni tasas de error sin observación.
8. Separar tres conclusiones: reglas verificadas, experiencia observada y aceptación del usuario. Una UI rechazada vuelve al diseño aunque pasen sus pruebas mecánicas.

Estructura mínima sugerida: `SKILL.md` corto y referencias sobre builds/inventarios, HUD/feedback y revisión de referencias/tareas. No fijar porcentajes de pantalla, tamaños o tiempos universales. No imponer controlador, móvil o minimalismo a todos los juegos.

Ruta de uso: `ui-design-core` para el problema y jerarquía → `game-ui-design` para experiencia de juego → `godot-ui-design` para implementación → `ui-visual-qa` para evidencia y corrección.

## 6. Próximo trabajo y criterio de avance

Primero crear la capa especializada con los criterios anteriores. Después elaborar una propuesta visual de taller de ensamblaje: bestia claramente dominante, piezas identificables, destinos y relación con habilidades visibles, detalle contextual y borrador inequívoco. Esa propuesta debe compararse con la captura rechazada antes de otra implementación extensa.

La revisión deberá permitir identificar la copia editada y el principal, reemplazar una modular, montar/intercambiar/retirar un mod y explicar qué cambió, sin consultar instrucciones externas. También debe demostrar cancelación y distinguir vista previa de configuración aplicada. No basta una lista de controles disponibles.

Este documento registra investigación y propuestas. No aprueba nuevos sistemas, no cambia la anatomía de montaje y no declara terminada la presentación artística. Mapa, refugio e historia conservan sus bloques separados.
