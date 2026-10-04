extends Resource
## Definición compartida; los consumidores reciben copias del payload.
@export var id := ""
@export var domain := ""
@export var payload: Dictionary = {}

func value() -> Dictionary:
	return payload.duplicate(true)
