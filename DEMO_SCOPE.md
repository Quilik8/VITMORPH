# Vitmorph · alcance vigente de la demo con assets

Actualizado: 4 octubre 2026, después de checkpoint-v0.7.0. Autoridad: instrucciones directas del usuario. Decisiones de producto; no se presentan como ya implementadas.

## Estado del proyecto

La demo prevista integra imágenes, sprites, sonido y demás contenido aportado por el usuario. La versión 0.7.0 es un prototipo de sistemas y una base recuperable. Las pruebas técnicas no certifican la demo final ni la aceptación de su UI o mapa.

Todos los assets los proporcionará el usuario. No generar imágenes ni inventar elecciones artísticas o narrativas pendientes. Lista de producción: [ASSET_REQUESTS.md](ASSET_REQUESTS.md).

## Decisiones confirmadas

| ID | Decisión | Consecuencia |
|---|---|---|
| D-01 | Refugio grande, con personajes, cercano a una ciudad | No reducirlo a un pequeño claro o punto de descanso |
| D-02 | Por ahora, entrada a otra instancia para acceder al refugio | Diseñar acceso, destino y retorno; no imponer el mismo mapa exterior |
| D-03 | Historia única, sin ramificaciones | No crear elecciones de argumento, rutas narrativas ni finales divergentes |
| D-04 | Demo con assets suministrados por el usuario | El material geométrico actual es provisional |
| D-05 | Cada bestia tiene su propia build | Identificar cada copia editada y distinguir edición de selección del principal |
| D-06 | Equipamiento combina selección y drag and drop | Ambos métodos deben usar las mismas reglas y validaciones |
| D-07 | Colección, habilidades y mods necesitan rediseño | La aceptación técnica anterior no es aprobación de la UX actual |
| D-08 | Primer mapa demasiado lineal | Replantear estructura antes de ampliarlo o vestirlo con arte |
| D-09 | Combate en el lugar de exploración | La instancia del refugio no autoriza una escena independiente para cada batalla |

D-01 a D-03 corrigen la propuesta del asistente de un refugio pequeño dentro del mismo mapa y cualquier interpretación de historia ramificada. Estas instrucciones posteriores tienen prioridad sobre documentos anteriores.

## Historia y presentación

La trama será una sola. Un registro de escenas y condiciones puede organizarla, pero no debe transformarse en elecciones de argumento. El usuario aportará o aprobará sinopsis, acontecimientos, personajes, diálogos y orden narrativo.

Presentación pendiente: diálogos sobre el mundo, sprites/retratos con fondos al estilo visual novel, o combinación. Ninguna opción quedó aprobada por ser propuesta en el chat. No cerrar cantidades de fondos y expresiones antes de elegir presentación y escenas.

Voces, cinemáticas, servicios comerciales, misiones secundarias y nuevas funciones de personajes no están autorizados por este documento.

## Instancia del refugio

La zona será amplia y tendrá personajes. Planta, lugares accesibles, elenco e interacciones están pendientes. No asumir que la demo debe construir una ciudad entera ni fijar edificios o habitantes.

Pendientes técnicos: ubicación del acceso, puntos de entrada/salida, persistencia y adaptación de guardado/derrota. El descanso y retorno actuales sirven como antecedente, no como diseño final del refugio.

Cambiar de instancia no define cómo se presentará la transición. La meta anterior de evitar pantallas de carga se conserva; la solución técnica está pendiente. No interpretar esta corrección como autorización automática para añadir una pantalla de carga.

## Builds y colección

Cada copia conserva identidad y build propias, incluso si comparte especie con otra. La biblioteca de habilidades es reutilizable. Mostrar inequívocamente la copia editada, dos fijas, dos modulares, ocho ranuras normales y dos especiales. Seleccionar para editar no la convierte en principal.

Selección y arrastre usarán el mismo servicio de validación. Layout, reemplazos, retiro de mods, comparación y cambios pendientes requieren brief y revisión del render. Los efectos especiales de ranuras especiales siguen sin definirse. El catálogo técnico no obliga a producir el mismo catálogo artístico.

## Exterior y enemigos

Replantear la distribución, conexiones, referencias visuales y espacios de encuentro; ampliar dimensiones no resuelve la linealidad. La crítica a enemigos visibles requiere una decisión posterior: no dar por aprobados todos visibles, todos ocultos, combates aleatorios, emboscadas o aparición por guion.

## Próximo trabajo de diseño

1. Brief de colección/builds con selección y arrastre.
2. Esquema del exterior y refugio, accesos y conexiones.
3. Escenas de la historia única y presentación.
4. Assets por contenido aprobado, cantidades y fichas.
5. Integración de una sección representativa antes de ampliar contenido.

## Continuidad para futuras sesiones

Leer AGENTS.md → DEMO_SCOPE.md → ASSET_REQUESTS.md. Después consultar DEMO_IMPLEMENTATION.md para mecánicas que siguen vigentes y DEMO_DELIVERY.md para evidencia del prototipo. Conservar checkpoint-v0.7.0 como referencia técnica. Mantener separados aprobado, implementado, propuesto y pendiente; los documentos históricos no sustituyen instrucciones posteriores del usuario.
