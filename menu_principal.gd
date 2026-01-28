extends Control


func _on_button_pressed() -> void:
	print("¡Botón pulsado correctamente!")
	# Usamos call_deferred para que el cambio de escena ocurra de forma segura
	get_tree().call_deferred("change_scene_to_file", "res://constructor_jardin.tscn")
