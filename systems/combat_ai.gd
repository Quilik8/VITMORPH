extends RefCounted
## Selección determinista; nunca modifica el estado del combate.

static func target_for(actor: Dictionary, skill: Dictionary, actors: Array[Dictionary]) -> Dictionary:
	var best: Dictionary = {}
	for candidate in actors:
		if candidate.hp <= 0 or (candidate.id == "main") == (actor.id == "main"):
			continue
		if actor.position.distance_to(candidate.position) > skill.range:
			continue
		if best.is_empty() or candidate.hp < best.hp:
			best = candidate
	return best

static func blocked_reason(actor: Dictionary, skill: Dictionary, actors: Array[Dictionary], retained: String, decision_turn: int) -> String:
	if actor.hp <= 0:
		return "Bestia derrotada"
	if actor.id == "main" and skill.id == retained:
		return "Retenida hasta liberar"
	var ready: int = actor.ready_at.get(skill.id, 0)
	if decision_turn < ready:
		return "Reutilización: %d elección(es)" % (ready - decision_turn)
	if skill.shield > 0:
		return "Ya tiene protección" if actor.shield > 0 else ""
	if target_for(actor, skill, actors).is_empty():
		return "Sin objetivo vivo en alcance"
	return ""

static func choose(actor: Dictionary, actors: Array[Dictionary], priority: String, retained: String) -> Dictionary:
	var valid: Array[Dictionary] = []
	for skill in actor.abilities:
		if blocked_reason(actor, skill, actors, retained, actor.turns).is_empty():
			valid.append(skill)
	var selected: Dictionary = {}
	var reason := ""
	if actor.id == "main":
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
			if skill.damage > 0 and (selected.is_empty() or skill.damage > selected.damage):
				selected = skill
				reason = "Ataque válido de mayor daño"
	if selected.is_empty() and not valid.is_empty():
		selected = valid[0]
		reason = "Única alternativa válida"
	if selected.is_empty():
		return {"actor_id": actor.id, "skill": {}, "target_id": "", "reason": "Sin habilidad válida: pierde esta oportunidad"}
	var target: Dictionary = actor if selected.shield > 0 else target_for(actor, selected, actors)
	return {"actor_id": actor.id, "skill": selected.duplicate(true), "target_id": target.id, "reason": reason}
