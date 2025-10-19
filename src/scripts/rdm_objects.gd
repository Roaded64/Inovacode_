extends Node

# --- PALAVRAS E OBJETOS ---
var palavras = ["IA", "BALDE", "CADEIRA", "PLANTA", "TENIS"]
var palavra_atual = ""
var id_atual = 0
var rodada = 0
var acertos = 0
var erros = 0
var max_rodadas = 3
var usados: Array = []
var soletrar_ativo: bool = true

# --- NÓS ---
@onready var c_int = $caixa/InteractionArea
@onready var tv_cor = $"../TV_Screen/soletrar/ColorRect"
@onready var tv_let = $"../TV_Screen/soletrar/Label"
@onready var fg = $"../CanvasLayer/fg"
var objetos = [$obj_1, $obj_2, $obj_3, $obj_4, $obj_5]

# --- CORES POR LETRA ---
var cores_letras = {
	"A": Color(1, 0, 0), "B": Color(0, 1, 0), "C": Color(0, 0, 1),
	"D": Color(1, 1, 0), "E": Color(1, 0, 1), "I": Color(0, 0, 0.5),
	"L": Color(0, 0.5, 0.5), "N": Color(1, 0, 0.5), "P": Color(0, 1, 0.5), 
	"R": Color(0.5, 0, 1), "S": Color(1, 0.5, 0.5), "T": Color(0.5, 1, 0.5)
}

var velocidade = 0.7

func _ready() -> void:
	if Main.cur_test == 2:
		c_int.interact = Callable(self, "_interact")
	
	var main = Main
	if main.has_signal("test_begin"): 
		main.connect("test_begin", Callable(self, "proxima_rodada"))
	
	if main.has_signal("test_end"): 
		main.connect("test_end", Callable(self, "sair"))
	
	if PrincipalHud.has_signal("end"):
		PrincipalHud.connect("end", Callable(self, "errou"))

# --- INTERAÇÃO COM OBJETO ---
func _interact():
	if not soletrar_ativo:
		return

	var obj_id = Main.objsegurando

	if obj_id == null:
		print("❗ Pegue algum objeto antes de interagir.")
		return

	print("🔍 Interagindo com objeto de ID:", obj_id)

	# Verifica se o ID do objeto segurado é o esperado
	if obj_id == id_atual:
		acertos += 1
		print("✅ Acertou!")

		_verifica(1)
		var index = id_atual - 1
		if index not in usados:
			usados.append(index)

		# ✅ Remove o objeto corretamente da cena ao acertar
		var node_name = "obj_%d" % obj_id
		var obj_node = get_node_or_null(node_name)

		if obj_node:
			obj_node.queue_free()
			print("🗑️ Objeto %s removido da cena." % node_name)
		else:
			print("⚠️ Objeto com nome %s não encontrado na cena." % node_name)
	else:
		Main.objsegurando = null
		erros += 1
		_verifica(0)
		print("❌ Errou! Tente novamente: %s (ID correto: %d, ID usado: %d)" % [palavra_atual, id_atual, obj_id])

	proxima_rodada()

# --- PRÓXIMA RODADA ---
func proxima_rodada():
	PrincipalHud.stop_timer()
	
	if rodada > 0:
		Main.is_cutscene = true
		fg.show()
		$"../ambience".stream_paused = true
		$".."._position()
		await get_tree().create_timer(1.5).timeout
		fg.hide()
		$"../ambience".stream_paused = false
		PrincipalHud._mission("Atenção na TV!")

	if acertos >= 2:
		finalizar_jogo()
	if erros >= 2:
		finalizar_jogo()
	
	await get_tree().create_timer(1.5).timeout
	
	if not soletrar_ativo:
		return
	if rodada >= max_rodadas:
		finalizar_jogo()
		return
	
	$"../TV_Screen/tentativas".hide()

	if erros > 0 and not (id_atual-1 in usados) and palavra_atual != "":
		await mostrar_palavra(palavra_atual)
		return

	var idx = sortear_indice_unico()
	if idx == -1:
		print("Acabaram as palavras disponíveis.")
		return

	rodada += 1
	palavra_atual = palavras[idx]
	id_atual = idx + 1
	print("%s (ID: %d)" % [palavra_atual, id_atual])

	await mostrar_palavra(palavra_atual)

# --- MOSTRAR PALAVRA NA TV ---
func mostrar_palavra(p: String):
	$"../TV_Screen/soletrar".show()
	$"../TV_Screen/TvSprite".frame = 1
	
	for letra in p:
		tv_let.text = letra
		if cores_letras.has(letra):
			tv_cor.color = cores_letras[letra]
		await get_tree().create_timer(velocidade).timeout
	tv_let.text = ""
	tv_cor.color = Color.from_hsv(0, 0, 0.81)
	Main.is_cutscene = false
	$"../TV_Screen/tentativas".show()
	PrincipalHud._mission("Coloque no cesto o objeto soletrado")
	await get_tree().create_timer(1).timeout
	PrincipalHud.define_timer(08.0)

func errou():
	erros += 1
	_verifica(0)
	rodada += 1

	proxima_rodada()

# --- SORTEIO ALEATÓRIO ---
func sortear_indice_unico() -> int:
	if usados.size() >= palavras.size():
		return -1
	var idx = randi() % palavras.size()
	while idx in usados:
		idx = randi() % palavras.size()
	return idx

# --- FINALIZAÇÃO DO JOGO ---
func finalizar_jogo():
	soletrar_ativo = false
	Main.is_cutscene = false

	# ✅ Remove todos os objetos restantes
	for nome in ["obj_1", "obj_2", "obj_3", "obj_4", "obj_5", "caixa"]:
		var node = get_node_or_null(nome)
		if node:
			node.queue_free()
	
	Main.is_cutscene = true
	$"../testes_map/chefe".position = Vector2(176, 116)
	$"../testes_map/chefe".flip_h = true
	$"../player_scene"._position(144, 116)
	PrincipalHud.hide()
	$"../TV_Screen/soletrar".hide()
	$"../TV_Screen/tentativas".hide()
	$"../TV_Screen/TvSprite".frame = 0
	
	await get_tree().create_timer(1.7).timeout
	DialogueManager.auto_advance = true
	DialogueManager.auto_advance_delay = 2  # segundos por linha

	if acertos >= 2:
		Main.ending = 4
		DialogueManager.show_dialogue_balloon(load("res://assets/dialogue_manager/dialogs/sala_de_teste/final.dialogue"))
	else:
		Main.ending = 3
		DialogueManager.show_dialogue_balloon(load("res://assets/dialogue_manager/dialogs/sala_de_teste/final_ruim.dialogue"))

func _verifica(aoe: int) -> void:
	var indice = str(rodada).pad_zeros(2) # transforma 1 → "01", 2 → "02", etc.
	var caminho = "../TV_Screen/tentativas/teste_%s" % indice
	var teste = get_node_or_null(caminho)
	if not teste:
		print("⚠️ Nó não encontrado:", caminho)
		return

	teste.frame = 1 if aoe == 1 else 2

func sair():
		fg.show()
		$"../ambience".stop()
		await get_tree().create_timer(1.5).timeout
		Transition.scene("res://src/scenes/misc/credits_scene.tscn")
