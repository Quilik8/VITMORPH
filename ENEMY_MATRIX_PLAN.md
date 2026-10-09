# Matriz enemiga: defensa y Vulnerabilidad

9 octubre 2026 · Propuesta para revisión. Autorizado preparar este plan; sus valores y nuevas reglas todavía no están aprobados para implementación.

## 1. Fuente y objetivo

Fuente de diseño: Documento Conceptual Maestro v1.0, sección 21. La matriz enemiga rompe una defensa general y permite aproximarse al daño potencial real. Los puzzles son opcionales, exclusivos del combate y no interrumpen el autobattler. Ignorarlos no debe degradar el funcionamiento normal de la build. La matriz propia sostiene/amplifica combos producidos por la build: requiere otro contrato.

Base técnica comprobada: COMBAT_MATRIX_DESIGN.md y COMBAT_MATRIX_DELIVERY.md. Hoy los anillos solo prueban interacción. No se atribuye retrospectivamente un efecto mecánico a esa entrega.

Objetivo de la siguiente prueba: que el jugador pueda relacionar defensa del objetivo, resolución de su matriz y daño recibido, mientras mantiene Priorizar/Retener y observa las intenciones.

## 2. Decisiones confirmadas y propuestas

Confirmado: un principal, combate continuo en el lugar de exploración, una matriz abierta, progreso independiente, comandos con validez y acciones elegidas conservadas. Ritmo 3,8 s; efecto a 2,2 s. Assets aplazados.

Propuesta acotada: una defensa porcentual explícita por actor, ruptura temporal mediante Rotación de Anillos, una ruptura por enemigo y encuentro. Solo un escenario de diagnóstico recibe esta defensa inicialmente. Los encuentros normales y fixtures históricos mantienen sus números; ampliar el sistema dependerá de la evaluación.

No se crean resistencias elementales, armadura por piezas, nuevos mods, niveles de defensa, inmunidades, recompensas, penalizaciones por fallar ni reglas de combos/Parry.

## 3. Contrato candidato de daño

Separar tres conceptos:

| Concepto | Significado | Procedencia |
|---|---|---|
| Daño potencial | Daño derivado de habilidad/build | Resolución actual de Potencia |
| Defensa general | Fracción del daño que mitiga el objetivo | Perfil técnico del actor, nueva propuesta |
| Protección | Absorción finita del siguiente impacto | Habilidad Defensa ya existente |

Orden propuesto: daño potencial → mitigación de defensa → absorción de protección → pérdida de PV. Redondear una vez tras mitigación, al entero próximo, mitades hacia arriba. No modificar el recurso de habilidad ni redondear contribuciones sucesivas.

```text
mitigacion_efectiva = 0 mientras Vulnerabilidad esté activa; defensa_base en otro caso
daño_tras_defensa = floor(daño_potencial × (1 − mitigacion_efectiva) + 0,5)
absorbido = min(proteccion, daño_tras_defensa)
daño_PV = daño_tras_defensa − absorbido
```

La ruptura elimina esa mitigación durante la ventana: no multiplica el daño potencial ni elimina Protección. El comportamiento de consumo de Protección conserva su contrato actual y se comprobará contra el código antes de integrar; este plan no redefine su duración ni acumulación.

Valores de ensayo propuestos: defensa 20 %, Vulnerabilidad 12 segundos del reloj de combate. Defensa 0 por defecto para referencias antiguas. Validar defensa en [0,1), daño no negativo y duración positiva; rechazar datos inválidos en catálogo/fixture, sin clamping silencioso que esconda errores.

| Habilidad / situación | Potencial | Defensa activa 20 % | Defensa rota |
|---|---:|---:|---:|
| Básico | 18 | 14 | 18 |
| Básico con Potencia | 22 | 18 | 22 |
| Cercano | 30 | 24 | 30 |
| Cercano con Potencia | 36 | 29 | 36 |
| Cercano, Protección 10 | 30 | 14 PV tras absorber 10 | 20 PV tras absorber 10 |
| Pulso periódico | 4 | 3 | 4 |

Propuesta: daño directo y pulsos periódicos usan la misma resolución. Cada pulso consulta defensa al ocurrir; aplicar desgaste no fija para siempre la defensa inicial. Ralentización, duración de estados, carga ATB, reutilizaciones y apoyo Copiar permanecen iguales. La ruptura no cuenta como daño ni vuelve elegible por sí sola una copia.

## 4. Ciclo de la matriz enemiga

1. Seleccionar un enemigo vivo del encuentro de prueba. Mostrar su defensa explícita y acceso contextual a matriz.
2. Abrir y manipular los anillos mientras transcurre combate. Cerrar/cambiar objetivo conserva progreso.
3. Resolver los tres anillos. Emitir una solicitud de ruptura con ID de encuentro y actor.
4. El motor valida actor activo, encuentro vigente, elegibilidad y ruptura no consumida. La UI no aplica estados por su cuenta.
5. Activar Vulnerabilidad durante 12 s; marcar ruptura consumida y conservar matriz alineada.
6. Al vencer la ventana, restaurar defensa base. La matriz sigue mostrando «Ruptura utilizada»; no se reinicia para obtener ventanas indefinidas.
7. Muerte/retirada/final limpian estado temporal. Repetir el encuentro comienza limpio.

No hay temporizador para resolver ni penalización por cerrar. El contador de Vulnerabilidad describe un efecto ya activado, no un plazo para completar el puzzle. Una ruptura por encuentro es una hipótesis de prueba, no una regla definitiva.

La defensa se consulta al impacto, no al elegir la acción: resolver durante una anticipación puede afectar ese impacto sin cambiar habilidad, objetivo o tiempos. Si una entrada de resolución coincide con un impacto ya procesado, no altera su resultado. Registrar un orden estable: procesar primero eventos de combate debidos hasta el instante de la entrada y después la solicitud. En el vencimiento exacto, Vulnerabilidad ya no está activa. Probar los límites de tiempo expresamente.

## 5. Integración técnica

- Datos de perfil: defensa base con valor predeterminado 0; sin añadir un mod Dureza ni vincularlo a fórmulas nuevas.
- Estado de encuentro por actor: vencimiento de Vulnerabilidad y ruptura consumida. No se exporta en guardado ni se transfiere a una copia obtenida.
- Servicio común de daño devuelve potencial, mitigado, absorbido y daño PV. Motor, pulsos, IA y diagnóstico consumen esa resolución.
- IA compara daño aprovechable con defensa y protección actuales. Para desgaste estima pulsos con vencimientos conocidos, sin simular muertes futuras ni futuras resoluciones del jugador.
- El controlador de anillos mantiene interacción/progreso; el motor resuelve elegibilidad y efecto. El estado alineado no equivale por sí solo a ruptura aceptada.
- Señales de ruptura aceptada/rechazada/expirada y daño resuelto. Actualización de HUD por eventos; reloj/contador visual mediante cadencia acotada, sin reconstrucción de controles.
- Snapshot de diagnóstico incluye defensa y desglose de impactos; no añade estos efectos efímeros a JSON de partida.
- Copia conserva perfil funcional según su contrato. Si más adelante la defensa se integra en perfiles reales, resolver su copia por definición, nunca copiando una Vulnerabilidad activa.

## 6. Presentación candidata

Extender la composición existente después de aplicar ui-design-core, godot-ui-design, vitmorph-game-ui y revisión real ui-visual-qa. No se propone otro rediseño general.

Primera lectura: objetivo seleccionado → «Defensa 20 %» → matriz → «Defensa rota · 12 s». En el campo, una marca compacta de estado; detalle del objetivo explica efecto sobre daño y coexistencia con Protección. El desglose completo pertenece a diagnóstico, no a otra tarjeta permanente.

Matriz resuelta: «Defensa rota» mientras activa; «Ruptura utilizada» al expirar. Matriz propia continúa identificada como prueba sin efecto. El botón no promete Vulnerabilidad sobre actores de diagnóstico sin defensa funcional habilitada. Foco, P/R, aviso de Parry y distribución estrecha conservan su contrato.

## 7. Orden de ejecución después de aprobar el contrato

### A. Resolución y pruebas aisladas

Crear resolución común, datos y estado efímero; probar redondeo, protección, daño directo/periódico, defensa 0 y catálogo inmutable. No cambiar recorrido normal.

### B. Ruptura por evento

Conectar resolución de anillos a solicitud validada, controlar una ruptura por actor, vencimiento y limpieza. Probar muerte, retirada y cierre/reapertura, y órdenes simultáneos.

### C. IA y presentación

Actualizar estimación ofensiva y explicar daño observado. Extender detalle contextual y estados compactos. Revisar cuatro tamaños lógicos, foco y entradas reales mediante MCP con probe previo.

### D. Evaluación jugable

Comparar el mismo enemigo, kit, posición y defensa en dos casos: ignorar matriz / resolverla. Repetir con presión directa, desgaste y control. Registrar daño, tiempo de encuentro, oportunidades de intervención y si fue posible completar una copia sin protección artificial contra muerte.

La primera evaluación debe comprobar que ignorar matriz permite una victoria normal. No aumentar PV ni agresividad solo para volverla obligatoria. Si la build de referencia no vence sin puzzle, revisar balance del escenario antes de ampliar contenido.

## 8. Aceptación y evidencia

- Valores de la tabla reproducibles; ruptura nunca supera potencial por sí sola.
- Protección permanece distinta de defensa; daño periódico sigue la misma vía.
- Aplicar en anticipación afecta próximo impacto elegible; no reescribe impactos resueltos.
- Repetir solicitud no extiende ni duplica ventana; matrix propia no rompe defensa enemiga.
- Elegibilidad rechaza actor muerto/retirado, encuentro anterior y solicitud repetida.
- Vencimiento exacto, deltas grandes y orden de eventos producen resultados estables.
- Ignorar puzzle, cerrar o cambiar objetivo no altera rendimiento/ATB de la build.
- Copiar, P/R, guardado y restauración conservan suites previas.
- Revisión MCP de resolución, expiración, acción e impacto, a 1200×820, 1018×696, 760×820 y 640×640 lógicos; registrar dimensiones físicas.
- Tres mediciones equivalentes y veinte ciclos: intervalos reales p50/p95/p99/máximo, tirones, CPU por scope, nodos/recursos/memoria gráfica. Corregir o justificar regresión >10 %; no sumar scopes anidados.
- Documentar resultados, límites, CHANGELOG, commit y subida por entrega. Solo integrar al recorrido después de revisión jugando.

## 9. Decisiones para cerrar antes del código

Paquete recomendado para la primera prueba: defensa porcentual 20 %, ruptura completa de esa mitigación durante 12 s, una ruptura por enemigo/encuentro, daño directo y periódico sujetos al mismo cálculo. Protección no se elimina.

Estas decisiones son candidatas. Su aprobación autorizaría A–D, no combos, Parry funcional, nuevas familias de puzzle ni defensa en todo el recorrido. Valores anteriores permanecen vigentes mientras este documento sea propuesta.
