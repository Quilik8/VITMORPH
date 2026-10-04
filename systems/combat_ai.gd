extends RefCounted
const Status = preload("res://systems/status_system.gd")
const Rules = preload("res://data/demo_rules.gd")
## Selección determinista; nunca modifica el estado del combate.

static func target_for(actor: Dictionary, skill: Dictionary, actors: Array[Dictionary]) -> Dictionary:
	var best: Dictionary = {}
	for candidate in actors:
		if not Status.active(candidate) or candidate.team == actor.team:
			continue
		if actor.position.distance_to(candidate.position) > skill.range:
			continue
		if best.is_empty() or candidate.hp < best.hp:
			best = candidate
	return best

static func blocked_reason(actor: Dictionary, skill: Dictionary, actors: Array[Dictionary], retained: String, decision_turn: int) -> String:
	if not Status.active(actor):
		return "Bestia derrotada"
	if actor.get("is_principal",false) and skill.id == retained:
		return "Retenida hasta liberar"
	var ready: int = actor.ready_at.get(skill.id, 0)
	if decision_turn < ready:
		return "Reutilización: %d elección(es)" % (ready - decision_turn)
	if skill.shield > 0:
		return "Ya tiene protección" if actor.shield > 0 else ""
	if target_for(actor, skill, actors).is_empty():
		return "Sin objetivo vivo en alcance"
	return ""

static func choose(actor: Dictionary, actors: Array[Dictionary], priority: String, retained: String, clock := 0.0) -> Dictionary:
	var valid: Array[Dictionary] = []
	for skill in actor.abilities:
		if blocked_reason(actor, skill, actors, retained, actor.turns).is_empty():
			valid.append(skill)
	valid.sort_custom(func(a,b): return a.get("order",100)<b.get("order",100))
	var selected: Dictionary = {}
	var reason := ""
	if actor.get("is_principal",false):
		for skill in valid:
			if skill.id == priority:
				selected = skill
				reason = "Prioridad válida"
				break
	if selected.is_empty() and actor.hp <= actor.max_hp * 0.4 and actor.shield == 0:
		for skill in valid:
			if skill.shield > 0:
				selected = skill
				reason = "Defensa: vida igual o inferior al 40 %"
				break
	if selected.is_empty():
		for skill in valid:
			if skill.get("status","")!="slow": continue
			var target := target_for(actor,skill,actors)
			if target.get("atb",0.0)>=50.0 and target.get("atb",0.0)<100.0 and float(target.get("states",{}).get("slow",{}).get("intensity",0))<Rules.SLOW_FRACTION:
				selected=skill; reason="Ralentizar carga avanzada"; break
	if selected.is_empty():
		var highest := -1.0
		for skill in valid:
			if skill.damage<=0: continue
			var target := target_for(actor,skill,actors)
			var extra := 0.0
			if skill.get("status","")=="dot": extra=Status.additional_dot(target,clock,float(skill.get("status_duration",Rules.DOT_DURATION)))
			var benefit: float = minf(float(target.hp),maxf(0.0,float(skill.damage)-float(target.shield))+extra)
			if benefit>highest:
				selected=skill; highest=benefit
				reason=("Extender desgaste" if target.get("states",{}).has("dot") else "Aplicar desgaste") if extra>0 else "Mayor daño aprovechable"
	if selected.is_empty() and not valid.is_empty():
		selected = valid[0]
		reason = "Única alternativa válida"
	if selected.is_empty():
		return {"actor_id": actor.id, "skill": {}, "target_id": "", "reason": "Sin habilidad válida: pierde esta oportunidad"}
	var target: Dictionary = actor if selected.shield > 0 else target_for(actor, selected, actors)
	return {"actor_id": actor.id, "skill": selected.duplicate(true), "target_id": target.id, "reason": reason}
