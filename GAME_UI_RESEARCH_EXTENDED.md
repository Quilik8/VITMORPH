# Vitmorph · amuletos y otras interfaces de mejoras

4 octubre 2026. Ampliación de [GAME_UI_RESEARCH.md](GAME_UI_RESEARCH.md), solicitada antes de crear la skill. Conclusiones como criterios de diseño, no como nuevas mecánicas aprobadas.

## Hollow Knight: objetos antes que fichas

Se inspeccionó en navegador la [captura completa del menú de amuletos](https://cdn.wikimg.net/en/hkwiki/images/archive/9/9e/20190228173348%21Charms_Set_1.png), archivada el 28 febrero 2019 y atribuida a Team Cherry en su [ficha](https://hollowknight.wiki/w/File:Charms_Set_1.png). Imagen original 1920×1080, observada ajustada a un viewport 1280×720. No se ejecutó el juego ni se evaluó navegación real.

Observación: colección en filas de iconos de silueta variada sin cajas individuales repetidas; configuración equipada y muescas separadas arriba; detalle contextual a la derecha; ornamento compartido que encuadra el conjunto. No es minimalismo sin personalidad. La captura muestra un estado sin amuletos equipados; no demuestra todos los estados de selección.

La [wiki comunitaria](https://hollowknight.wiki/w/Charms) documenta muescas y sobrecarga con respuesta visual. Las [preguntas de jugadores sobre esa apariencia](https://www.reddit.com/r/HollowKnight/comments/l27adz) muestran que una señal expresiva puede necesitar explicación. Una [recreación comunitaria del menú](https://www.reddit.com/r/HollowKnight/comments/gkrw0q) recibe elogios a su suavidad y comentarios sobre estados ausentes; evalúa esa recreación, no constituye aprobación universal del original.

**Para Vitmorph:** identidad y silueta de las mejoras, colección legible y detalle de la pieza seleccionada. Mantener la bestia protagonista porque aquí el objetivo es ensamblarla. No introducir muescas, sobrecarga, bancos ni restricciones de Hollow Knight. Tampoco confiar solo en iconos o color para explicar reglas.

## Monster Hunter: apariencia y uso pueden divergir

Un [debate sobre Monster Hunter World](https://www.reddit.com/r/MonsterHunterWorld/comments/1dtp3c1/am_i_the_only_one_who_thinks_the_ui_is_beautiful/) elogia tema, fuentes e iconos, mientras otros participantes critican navegación, organización y retrasos por animación. Son experiencias distintas, no métricas representativas.

Un [hilo sobre controles y decoraciones en Monster Hunter Wilds](https://www.reddit.com/r/MonsterHunter/comments/1je0721) describe inconsistencias entre mostrar nombre y mostrar efecto en piezas disponibles/equipadas. Se consultó el resultado indexado; la apertura completa falló. No se afirma que ese problema histórico continúe en su versión actual. No confundir Wilds con World.

**Para Vitmorph:** identidad temática acompañada del efecto pertinente, consistente entre inventario y montaje; evitar submenús redundantes y animaciones que bloqueen cada operación. Una UI bonita requiere también acceso rápido y estados fiables.

## Hades: contexto disponible al decidir

Las [notas oficiales de 2019](https://www.supergiantgames.com/blog/hades-welcome-to-hell-update-patch-notes/) registran mejoras de feedback de aspectos y acceso al overlay de bendiciones durante interacciones. Las [notas oficiales de lanzamiento de 2020](https://www.supergiantgames.com/blog/hades-updates/) documentan consulta de listas de bendiciones desde el códice y desde la selección. Son antecedentes históricos documentales; no se inspeccionó un render actual.

El [proyecto comunitario Improved Boon Info UI para Hades II](https://github.com/SMarechalBE/Hades-2-Improved-Boon-Info-UI) busca distinguir requisitos aún alcanzables. Es evidencia de una necesidad del autor, no de consenso; se leyó su descripción y no se instaló ni ejecutó.

**Para Vitmorph:** información de compatibilidad donde se decide, y explicación del motivo de bloqueo. No trasladar elecciones aleatorias, bendiciones o progresión roguelike.

## Dead Cells: adquirido, disponible y elegido no son lo mismo

Las [preguntas sobre desbloqueo de mutaciones](https://www.reddit.com/r/deadcells/comments/rrfevl) y [consejos sobre selección y cambio de build](https://www.reddit.com/r/deadcells/comments/1tnece2/a_question_about_mutations/) permiten identificar una distinción conceptual útil: obtener algo no equivale a tenerlo seleccionado. Se consultó texto indexado; no se revisó visualmente su menú ni se deriva un ranking de UI de esos hilos.

**Para Vitmorph:** separar biblioteca desbloqueada, instancia disponible/ocupada y equipamiento del borrador/aplicado. No importar costes de reinicio ni límites de mutaciones.

## Síntesis aplicada a la skill

La skill creada es [vitmorph-game-ui](.agents/skills/vitmorph-game-ui/SKILL.md), especializada en el proyecto. Integra ensamblaje, HUD y revisión por tareas; enlaza documentos vigentes y conserva las reglas confirmadas. Su fuente está en Git y AGENTS.md exige usarla en UI/UX de Vitmorph. La instalación personal apunta a esa fuente, evitando dos copias divergentes.

La validación de estructura y el repaso de escenarios de decisión no certifican eficacia en una UI futura. El editor actual sigue rechazado. Esta entrega crea la herramienta de trabajo y documenta investigación; no rediseña todavía la pantalla ni incorpora assets.

## Comprobaciones de esta entrega

- `quick_validate.py` sobre la fuente del repositorio: resultado **Skill is valid!**. Comprueba estructura/frontmatter; no evalúa calidad visual.
- Enlace personal `C:\Users\jp_va\.codex\skills\vitmorph-game-ui` de tipo Junction hacia `D:\Vitmorph\.agents\skills\vitmorph-game-ui`; lectura de SKILL.md a través del enlace confirmada. No se guarda configuración personal absoluta dentro del paquete de la skill.
- Repaso de escritorio de instrucciones, sin simular usuarios ni ejecutar el juego:

| Solicitud hipotética | Decisión que exige la skill | Resultado del repaso |
|---|---|---|
| «Cambia todos los cuadrados por círculos» para solucionar el rechazo | Revisar jerarquía y relaciones; geometría aislada insuficiente, respetando la intención actual del usuario | Cubierto en entrada y review.md |
| «Equipa este mod ocupado en otra copia» | Indicar propietaria; retirar/aplicar allí antes del traslado; no convertir copia editada en principal | Cubierto en assembly.md |
| «Copia el menú de Hollow Knight» | Aprovechar identidad de piezas; mantener reglas propias, sin muescas/sobrecarga | Cubierto en assembly.md |
| No es posible obtener render | Informar límites y dejar QA visual pendiente; no sustituir por pruebas de código | Cubierto en entrada y review.md |
| Otra sesión trabaja en una copia del repositorio | Resolver raíz desde workspace e identidad, usar fuente local versionada y leer decisiones vigentes | Cubierto en entrada y AGENTS.md |
| Revisar cola y comandos de combate | Secuencia con repeticiones, Priorizar/Retener, Copiar como apoyo y acciones iniciadas conservadas | Cubierto en combat.md |

Estas comprobaciones son revisión de cobertura documental, no una evaluación independiente del comportamiento de otro agente. La prueba decisiva será aplicar la skill al siguiente diseño, observarlo y corregirlo con el usuario.
