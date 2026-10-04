extends RefCounted
const Rules = preload("res://data/demo_rules.gd")
const EPS := 0.000001

static func active(actor: Dictionary) -> bool:
	return actor.hp > 0 and not actor.get("retired",false)

static func speed(actor: Dictionary, clock: float) -> float:
	var slow: Dictionary = actor.get("states",{}).get("slow",{})
	return actor.speed * (1.0-float(slow.intensity)) if not slow.is_empty() and slow.expires>clock+EPS else float(actor.speed)

static func apply(actor: Dictionary, kind: String, clock: float, intensity := -1.0, derived_duration := -1.0) -> void:
	if not active(actor) or kind not in ["dot","slow"]: return
	if not actor.has("states"): actor.states = {}
	var duration: float = Rules.DOT_DURATION if kind=="dot" else Rules.SLOW_DURATION
	if derived_duration>=0.0: duration=derived_duration
	var strength: float = (Rules.DOT_DAMAGE if kind=="dot" else Rules.SLOW_FRACTION) if intensity<0 else intensity
	var previous: Dictionary = actor.states.get(kind,{})
	if previous.is_empty():
		actor.states[kind] = {"intensity":strength,"expires":clock+duration,"next":clock+Rules.DOT_INTERVAL if kind=="dot" else INF}
	else:
		previous.intensity = maxf(previous.intensity,strength)
		previous.expires = maxf(previous.expires,clock+duration)

static func pulse_count(next: float, expires: float) -> int:
	return maxi(0,int(floor((expires-next+EPS)/Rules.DOT_INTERVAL))+1)

static func additional_dot(target: Dictionary, clock: float, duration: float) -> float:
	var current: Dictionary=target.get("states",{}).get("dot",{})
	if current.is_empty():
		return pulse_count(clock+Rules.DOT_INTERVAL,clock+duration)*Rules.DOT_DAMAGE
	var previous := pulse_count(current.next,current.expires)*float(current.intensity)
	var renewed := pulse_count(current.next,maxf(current.expires,clock+duration))*maxf(float(current.intensity),Rules.DOT_DAMAGE)
	return maxf(0.0,renewed-previous)

static func time_to_charge(actor: Dictionary, amount: float, start: float) -> float:
	var slow: Dictionary = actor.get("states",{}).get("slow",{})
	var seconds := maxf(0.0, float(slow.get("expires",start))-start)
	var rate: float = speed(actor,start)
	var reduced := seconds*rate
	return amount/rate if amount<=reduced else seconds+(amount-reduced)/float(actor.speed)
