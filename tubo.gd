extends Area2D

signal toco_al_jugador(tubo)


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body.is_in_group("jugador"):
		toco_al_jugador.emit(self)
