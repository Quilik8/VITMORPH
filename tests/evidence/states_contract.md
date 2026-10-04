# Reloj, estados e IA

24 comprobaciones nuevas aprobadas por MCP (demo_combat_checks.json). Separadas de la suite histórica.
El reloj divide el delta por llegada ATB, pulso, expiración e impacto/final de presentación.
Daños debidos preceden a impactos; los resultados de copia ocuparán el siguiente punto antes de expiraciones.
Un presupuesto de 2048 eventos conserva el tiempo pendiente; no se salta simulación por deltas extremos.
Ralentización no borra carga ni modifica ready_time. La previsión integra su expiración conocida.
El motor y la IA utilizan equipos e is_principal, no el texto del ID.
Datos de estado se separan del catálogo; reaplicar conserva intensidad mayor, cadencia y vencimiento mayor.
La suite incluye paridad delta 60 s / 600 pasos, daño protegido, muerte periódica y cola repetida.
