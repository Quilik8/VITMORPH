extends RefCounted
signal changed
signal completed(actor: Dictionary)
const Rules = preload("res://data/demo_rules.gd")
const Status = preload("res://systems/status_system.gd")
var pending_id := ""
var process: Dictionary = {}
var message := ""

func eligibility(actor: Dictionary, main: Dictionary) -> String:
	if actor.is_empty() or not Status.active(actor): return "Objetivo no disponible"
	if main.is_empty() or actor.team==main.team: return "Selecciona un enemigo"
	if not actor.has("definition_id") or not actor.has("build"): return "Escenario de diagnóstico · copia no disponible"
	if actor.hp>actor.max_hp*Rules.COPY_THRESHOLD: return "Debilita hasta ≤30 % PV"
	return ""

func request(actor: Dictionary, main: Dictionary) -> Dictionary:
	if pending_id!="" or not process.is_empty(): return {"ok":false,"error":"Ya hay una copia en curso"}
	var reason := eligibility(actor,main)
	if reason!="": return {"ok":false,"error":reason}
	pending_id=actor.id
	message="Solicitud pendiente · siguiente oportunidad"
	changed.emit()
	return {"ok":true}

func cancel() -> void:
	if pending_id=="": return
	pending_id=""; message="Solicitud cancelada"; changed.emit()

func dispatch(actor: Dictionary, main: Dictionary) -> Dictionary:
	if pending_id=="": return {}
	pending_id=""
	var reason := eligibility(actor,main)
	if reason!="": message="Solicitud cancelada: "+reason; changed.emit(); return {}
	message="Acción de apoyo · Copiar"
	changed.emit()
	return {"actor_id":main.id,"target_id":actor.id,"kind":"copy","reason":"Reserva de la siguiente oportunidad","skill":{"id":"copy_support","name":"Copiar","damage":0,"shield":0,"range":0.0,"cooldown":0}}

func begin(actor: Dictionary, main: Dictionary, clock: float) -> void:
	# La elegibilidad de vida se comprueba al despacho; después solo importa seguir vivo.
	if actor.is_empty() or not Status.active(actor) or not Status.active(main): fail("Objetivo perdido durante el apoyo"); return
	process={"target_id":actor.id,"start":clock,"finish":clock+Rules.COPY_SECONDS}
	message="Copiando · mantén vivo al objetivo"
	changed.emit()

func fail(reason: String) -> void:
	pending_id=""; process={}; message="Copia fallida: "+reason; changed.emit()

func update(actor: Dictionary, main: Dictionary, clock: float) -> void:
	if process.is_empty(): return
	if actor.is_empty() or not Status.active(actor): fail("Objetivo derrotado o retirado"); return
	if main.is_empty() or not Status.active(main): fail("Principal derrotado"); return
	if clock+Status.EPS>=process.finish:
		process={}
		actor.retired=true; actor.atb=0.0; actor.ready_time=-1.0; actor.states.clear()
		message="Copia obtenida · original retirado vivo"
		completed.emit(actor.duplicate(true))
		changed.emit()

func reset() -> void:
	pending_id=""; process={}; message=""; changed.emit()

func snapshot(clock: float) -> Dictionary:
	return {"pending_id":pending_id,"process":process.duplicate(true),"message":message,"progress":clampf((clock-float(process.get("start",clock)))/Rules.COPY_SECONDS,0.0,1.0) if not process.is_empty() else 0.0}
