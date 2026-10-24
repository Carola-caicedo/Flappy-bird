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


func _ready():
	construir()


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
