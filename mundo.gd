extends "res://bloques.gd"

const MAPA = [
	"################################################################",
	"        |     |     |     |     |     |     |     |             ",
	"        |     |           |     |     |     |     |             ",
	"              |     o     |     |           |     |             ",
	"        .     |                 |     .     |                   ",
	"                    |     .     |                 .             ",
	"        |     o     |                 |     .                   ",
	"        |           |     |     .     |           |             ",
	"        |     |     |     |           |     |     |             ",
	"################################################################",
]

var moneda_escena = preload("res://moneda.tscn")
var pluma_escena = preload("res://pluma.tscn")
var tubo_escena = preload("res://tubo.tscn")

var puntaje = 0
var modo_poder = false
var vidas = 3
var juego_terminado = false

@onready var jugador = $Pajaro
@onready var timer_poder = $TimerPoder


func _ready():
	construir()
	
	# Conexión de señales de monedas
	for item in get_tree().get_nodes_in_group("monedas"):
		item.recogido.connect(_on_recogido)
	
	# Conexión de señales de tubos enemigos
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.toco_al_jugador.connect(_on_enemigo_toco)
	
	# Conexión del Timer de poder
	timer_poder.timeout.connect(_on_timer_poder_timeout)
	
	# Conexion de señales de piso y techo
	jugador.choco_con_bloque.connect(_on_paredes_toco)
	
	actualizar_hud()


func _on_paredes_toco():
	if jugador.muriendo or juego_terminado:
		return
	
	if modo_poder:
		return
	
	# 3. Sin poder:
	vidas -= 1
	actualizar_hud()
	
	if vidas <= 0:
		juego_terminado = true
		$HUD/Mensaje.text = "Perdiste"
		jugador.set_physics_process(false)
		jugador.morir()
	else:
		jugador.morir()
	

func _on_recogido(valor, da_poder):
	puntaje += valor
	actualizar_hud()
	
	if da_poder:
		activar_poder()
	
	if get_tree().get_nodes_in_group("monedas").size() == 0:
		$HUD/Mensaje.text = "¡Pasaste todos los huecos!"


func activar_poder():
	modo_poder = true
	print("poder: sí")
	
	# Pone los tubos semi-transparentes
	cambiar_transparencia_tubos(true)
	
	# El Timer reinicia la cuenta regresiva desde 0 al volver a llamar a start()
	timer_poder.start(5.0)

func cambiar_transparencia_tubos(transparente: bool):
	# 0.4 de alfa (40% opacidad) al tener poder, 1.0 (100% opacidad) al terminar
	var alfa = 0.4 if transparente else 1.0
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.modulate.a = alfa


func _on_timer_poder_timeout():
	modo_poder = false
	print("poder: no")
	# Restaura la transparencia de los tubos
	cambiar_transparencia_tubos(false)


func _on_enemigo_toco(_enemigo):
	# 1. Si el pájaro está muriendo, o el juego ya terminó, no hagan nada.
	if jugador.muriendo or juego_terminado:
		return
	
	# 2. Con poder: el tubo no hace daño: no pasa nada.
	if modo_poder:
		return
	
	# 3. Sin poder:
	vidas -= 1
	actualizar_hud()
	
	if vidas <= 0:
		juego_terminado = true
		$HUD/Mensaje.text = "Perdiste"
		jugador.set_physics_process(false)
		jugador.morir()
	else:
		jugador.morir()


func actualizar_hud():
	$HUD/Puntaje.text = "Puntaje: %d | Vidas: %d" % [puntaje, vidas]


func construir():
	construir_bloques(MAPA, Color(0.35, 0.65, 0.2, 1))
	for fila in MAPA.size():
		for col in MAPA[fila].length():
			var escena = null
			match MAPA[fila][col]:
				".":
					escena = moneda_escena
				"o":
					escena = pluma_escena
				"|":
					escena = tubo_escena
			if escena:
				var nodo = escena.instantiate()
				nodo.position = Vector2(col + 0.5, fila + 0.5) * CELDA
				$Mapa.add_child(nodo)
