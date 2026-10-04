# Vitmorph

- Antes de continuar, leer DEMO_SCOPE.md y ASSET_REQUESTS.md: alcance vigente, decisiones posteriores y lista de producción. No reconstruir requisitos desde el chat ni dar pendientes por aprobados.
- Refugio grande con personajes, cercano a una ciudad; por ahora se accede entrando a otra instancia. El combate sigue en el lugar de exploración. Presentación de la transición pendiente.
- Historia única sin ramificaciones. Presentación narrativa pendiente. Todos los assets los aporta el usuario. checkpoint-v0.7.0 es base técnica, no demo final con assets ni UX aprobada.

- Usar el Godot MCP configurado y comprobar conexión con una consulta de solo lectura antes de afirmar evidencia de editor/runtime. Mantener un editor y un addon; no desactivar el MCP requerido para continuar.
- El jugador navega por un mundo continuo y multidireccional. El combate ocurre en ese lugar; HUD solo en combate. No añadir pantallas de preparación ni transición previa a cada encuentro.
- Las builds las arma el jugador. El editor voluntario está aprobado en DEMO_IMPLEMENTATION.md, pausa exploración y se bloquea en combate; no introducir otros menús por iniciativa propia.
- Movimiento futuro de bestias durante combate automático. Movimiento como acción/coste ATB no aprobado.
- Cola de sucesos con repeticiones. Comandos: Priorizar y Retener. Mantener validez y acciones ya elegidas. Copiar es apoyo, no un tercer comando de habilidades.
- No generar imágenes. Separar diseño aprobado, hipótesis, preguntas y decisiones descartadas.
- UI/UX requieren fase explícita de diseño: objetivo, jerarquía, acción, contexto, estados, restricciones y dirección visual antes de implementar. Preservar el Theme actual.
- Cambios de UI: aplicar ui-design-core, godot-ui-design y ui-visual-qa cuando sea posible observar el render. Código no sustituye revisión visual. Revisar y corregir los renders importantes.
- Versionar cambios con commits descriptivos, actualizar CHANGELOG.md y conservar evidencias y límites de validación. Excluir cachés, temporales, credenciales y configuración personal.
