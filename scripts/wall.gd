extends Area2D


func _on_wall_body_entered(body):
	body.morrer()
