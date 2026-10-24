extends "res://bloques.gd"
# Base del Taller 4. construir() arma el nivel a partir del MAPA:
# "#" bloque, "." moneda, "o" pluma, "|" tubo.

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


func _ready():
	construir()
	for item in get_tree().get_nodes_in_group("monedas"):
		item.recogido.connect(_on_recogido)


func _on_recogido(valor, da_poder):
	puntaje += valor
	$HUD/Puntaje.text = "Puntaje: %d" % puntaje
	
	if da_poder:
		activar_poder()
	
	# Verificación de victoria con conteo del grupo
	if get_tree().get_nodes_in_group("monedas").size() == 0:
		$HUD/Mensaje.text = "¡Pasaste todos los huecos!"


func activar_poder():
	modo_poder = true
	print("poder: sí")
	await get_tree().create_timer(5.0).timeout
	modo_poder = false
	print("poder: no")


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
