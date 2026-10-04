extends Node
signal saved(sequence: int)
signal failed(reason: String)
const SCHEMA := 1
var path := "user://vitmorph_demo.json"
var worker: Thread
var pending := ""
var sequence := 0
var confirmed := 0
var status := "Sin guardado"
var blocked := false
var last_write_usec := 0

func _ready() -> void:
	set_process(false)

func create_checkpoint(snapshot: Dictionary) -> Dictionary:
	if blocked: return {"ok":false,"error":status}
	sequence+=1
	var document := {"schema":SCHEMA,"sequence":sequence,"snapshot":snapshot.duplicate(true)}
	pending=JSON.stringify(document)
	status="Guardando…"
	if worker==null: dispatch()
	set_process(true)
	return {"ok":true,"sequence":sequence}

func dispatch() -> void:
	if pending=="": return
	var serialized := pending
	pending=""
	worker=Thread.new()
	var error := worker.start(write_file.bind(serialized,path))
	if error!=OK:
		worker=null; status="No se pudo iniciar guardado: %d"%error; failed.emit(status)

static func read_document(filename: String) -> Dictionary:
	if not FileAccess.file_exists(filename): return {}
	var file := FileAccess.open(filename,FileAccess.READ)
	if file==null: return {}
	var parser := JSON.new()
	if parser.parse(file.get_as_text())!=OK: return {}
	return parser.data if parser.data is Dictionary else {}

static func write_file(serialized: String, filename: String) -> Dictionary:
	var stamp := Time.get_ticks_usec()
	var temporary := filename+".tmp"
	var file := FileAccess.open(temporary,FileAccess.WRITE)
	if file==null: return {"ok":false,"error":"No se pudo crear archivo temporal"}
	file.store_string(serialized); file.flush()
	var error := file.get_error()
	file.close()
	if error!=OK: return {"ok":false,"error":"Fallo al escribir archivo temporal: %d"%error}
	var verified := read_document(temporary)
	if verified.is_empty() or verified.get("schema",0)!=SCHEMA or JSON.stringify(verified)!=JSON.stringify(JSON.parse_string(serialized)):
		return {"ok":false,"error":"No se pudo comprobar el archivo temporal"}
	var previous := read_document(filename)
	if not previous.is_empty() and previous.get("schema",0)==SCHEMA:
		error=DirAccess.copy_absolute(filename,filename+".bak.tmp")
		if error!=OK: return {"ok":false,"error":"No se pudo conservar respaldo: %d"%error}
		error=DirAccess.rename_absolute(filename+".bak.tmp",filename+".bak")
		if error!=OK: return {"ok":false,"error":"No se pudo sustituir respaldo: %d"%error}
	error=DirAccess.rename_absolute(temporary,filename)
	if error!=OK: return {"ok":false,"error":"No se pudo sustituir guardado: %d"%error}
	return {"ok":true,"sequence":int(verified.sequence),"usec":Time.get_ticks_usec()-stamp}

func complete_worker() -> void:
	var result: Dictionary = worker.wait_to_finish()
	worker=null
	if result.ok:
		confirmed=maxi(confirmed,result.sequence)
		last_write_usec=result.usec
		status="Guardado" if pending=="" else "Guardando…"
		saved.emit(confirmed)
	else:
		status=result.error; failed.emit(status)
	if pending!="": dispatch()
	else: set_process(false)

func _process(_delta: float) -> void:
	if worker!=null and not worker.is_alive(): complete_worker()

func flush() -> void:
	while worker!=null or pending!="":
		if worker==null: dispatch()
		if worker!=null: complete_worker()

func restore_checkpoint(validator: Callable) -> Dictionary:
	flush()
	var found := false
	var reasons: Array[String]=[]
	for filename in [path,path+".bak"]:
		if not FileAccess.file_exists(filename): continue
		found=true
		var document := read_document(filename)
		if document.is_empty(): reasons.append("Archivo corrupto: "+filename); continue
		if document.get("schema",0)!=SCHEMA: blocked=true; reasons.append("Esquema incompatible: "+filename); continue
		var snapshot = document.get("snapshot",{})
		if not snapshot is Dictionary: reasons.append("Snapshot inválido"); continue
		var validation: Dictionary = validator.call(snapshot)
		if not validation.ok: blocked=true; reasons.append(validation.error); continue
		sequence=int(document.get("sequence",0)); confirmed=sequence
		status="Guardado recuperado" if filename==path else ("Respaldo recuperado · escritura bloqueada · " if blocked else "Respaldo recuperado · ")+"; ".join(reasons)
		return {"ok":true,"snapshot":snapshot.duplicate(true),"backup":filename!=path}
	if found:
		blocked=true
		status="Guardado conservado: "+"; ".join(reasons)
		failed.emit(status)
	return {"ok":false,"error":status,"found":found}

func _exit_tree() -> void:
	flush()
