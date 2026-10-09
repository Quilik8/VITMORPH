extends RefCounted
## Consulta pura compartida por impactos, pulsos y valoración de IA.
const BREAK_SECONDS := 12.0
const TEST_DEFENSE := 0.20
const EPS := 0.000001

static func valid_defense(value: float) -> bool:
	return is_finite(value) and value>=0.0 and value<1.0

static func vulnerable(target: Dictionary, clock: float) -> bool:
	return float(target.get("vulnerability_until",-1.0))>clock+EPS

static func after_defense(target: Dictionary, amount: int, clock: float) -> int:
	var defense: float=0.0 if vulnerable(target,clock) else float(target.get("defense",0.0))
	return int(floor(maxi(0,amount)*(1.0-defense)+0.5))

static func preview(target: Dictionary, amount: int, clock: float) -> Dictionary:
	var potential:=maxi(0,amount)
	var remaining:=after_defense(target,potential,clock)
	var absorbed:=mini(maxi(0,int(target.get("shield",0))),remaining)
	return {"potential":potential,"mitigated":potential-remaining,"absorbed":absorbed,"damage":remaining-absorbed}

static func additional_dot(target: Dictionary, clock: float, duration: float) -> float:
	var current: Dictionary=target.get("states",{}).get("dot",{})
	var next: float=float(current.get("next",clock+4.0))
	var old_end: float=float(current.get("expires",clock))
	var new_end: float=maxf(old_end,clock+duration)
	var total:=0.0
	while next<=new_end+0.000001:
		var previous:=after_defense(target,int(current.get("intensity",0)),next) if next<=old_end+0.000001 else 0
		var renewed:=after_defense(target,maxi(4,int(current.get("intensity",0))),next)
		total+=maxi(0,renewed-previous)
		next+=4.0
	return total
