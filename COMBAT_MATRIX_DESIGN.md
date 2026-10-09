# HUD y matrices de combate · contrato aprobado

9 octubre 2026. Autoridad: plan solicitado por el usuario. Solo combate; nunca puzzles de exploración.

Objetivo: manipular una matriz mientras continúan autobattler, cola y comandos. Mundo protegido, misma escena y mismas posiciones. Theme carbón/marfil/cobre existente.

Jerarquía: cola y acción actual arriba; campo libre; habilidades/comandos abajo; matriz contextual derecha (320 px, ancho lógico >=1000) o debajo (220 px). Por debajo de 640×640 se cierra conservando progreso. Diagnóstico y fórmulas no dominan el juego. Containers distribuyen regiones; no superponer franjas de alturas fijas sobre la arena.

Rotación de Anillos: tres anillos, ocho pasos, iniciales 1/3/5, destino visible 0. Selección por ratón/arriba-abajo; giro por botones/izquierda-derecha. Escape cierra, Tab navega. Una matriz abierta; estado independiente por actor/encuentro; muerte/retirada/final limpian estado. No se guarda en disco. Resolución sin efecto mecánico.

Aviso Parry de diagnóstico: un segundo, entrada Espacio, sin robar foco ni alterar combate. No hay Parry funcional. Matriz enemiga futura rompe defensa para Vulnerabilidad; propia sostiene/amplifica combos existentes. Matemática pendiente, no inventada aquí.

Validar suite, ratón/teclado MCP, dimensiones reales, actores arriba/abajo/diagonal, tres mediciones equivalentes y veinte ciclos. Resultado artístico y comprensión final requieren revisión del usuario. Mapa, cura y sustitución fuera de este bloque.

Resultados de implementación y límites: COMBAT_MATRIX_DELIVERY.md.
